import 'package:bbs_sales_app/data/models/customer/customer_name_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../../data/models/quotation/quotation_model.dart';
import '../../../../data/models/quotation/quotation_detail_model.dart';
import '../../../../data/models/quotation/sales_quotation_post_model.dart';
import '../../../../data/services/quotation/quotation_repository.dart';
import '../../../../data/models/customer/customer_model.dart';
import '../../../../data/services/customer/customer_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotationProvider with ChangeNotifier {
  final QuotationRepository _quotationRepository = QuotationRepository();
  final CustomerRepository _customerRepository = CustomerRepository();

  List<Quotation> _quotations = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _error;

  int _page = 1;
  final int _paginate = 15;
  bool _hasMore = true;

  String? _searchKeyword;
  String? _filterCustomer;
  String? _filterStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  List<CustomerSimpleModel> _customerSearchResults = [];
  CustomerSimpleModel? _selectedCustomerFilter;

  QuotationDetail? _selectedQuotation;
  bool _isDetailLoading = false;
  String? _detailError;

  bool _isSubmitting = false;
  String? _submitError;
  String? _lastCreatedQuotationId;

  // Dummy data for filters
  final List<String> _customerList = ['Customer A', 'Customer B', 'Customer C'];
  final List<String> _statusList = [
    'Draft',
    'In Approval',
    'Revision',
    'Approved',
    'Rejected',
  ];

  List<Quotation> get quotations => _quotations;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get filterCustomer => _filterCustomer;
  String? get filterStatus => _filterStatus;
  List<String> get customerList => _customerList;
  List<String> get statusList => _statusList;
  List<CustomerSimpleModel> get customerSearchResults => _customerSearchResults;
  CustomerSimpleModel? get selectedCustomerFilter => _selectedCustomerFilter;
  QuotationDetail? get selectedQuotation => _selectedQuotation;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  String? get lastCreatedQuotationId => _lastCreatedQuotationId;

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setCustomerFilter(String? customerId) {
    _filterCustomer = customerId;
    notifyListeners();
  }

  void setSelectedCustomer(CustomerSimpleModel? customer) {
    _selectedCustomerFilter = customer;
    _filterCustomer = customer?.id;
    notifyListeners();
  }

  void setStatusFilter(String? statusId) {
    _filterStatus = statusId;
    notifyListeners();
  }

  Future<void> searchCustomers(
    String token,
    String query, [
    String? salesId,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unitBusinessId = prefs.getString('unit_bussiness_id');

      if (unitBusinessId == null) return;

      _customerSearchResults = await _customerRepository.fetchListCustomersName(
        token,
        search: query,
        salesId: salesId,
        unitBusinessId: unitBusinessId,
      );
      notifyListeners();
    } catch (e) {
      // Handle error silently or expose if needed
    }
  }

  Future<void> fetchQuotations(
    String salesId,
    String token, {
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _quotations = [];
      _isLoading = true;
    } else {
      if (_isLoading || !_hasMore) return;
      _isFetchingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final newQuotations = await _quotationRepository.fetchQuotations(
        salesId,
        token,
        page: _page,
        paginate: _paginate,
        search: _searchKeyword,
        filter_column_customer: _filterCustomer,
        filter_column_status: _filterStatus,
        startDate: _startDate != null
            ? DateFormat('yyyy-MM-dd').format(_startDate!)
            : null,
        endDate: _endDate != null
            ? DateFormat('yyyy-MM-dd').format(_endDate!)
            : null,
      );

      if (newQuotations.length < _paginate) {
        _hasMore = false;
      }

      if (isRefresh) {
        _quotations = newQuotations;
      } else {
        _quotations.addAll(newQuotations);
      }

      _page++;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (isRefresh) {
        _isLoading = false;
      } else {
        _isFetchingMore = false;
      }
      notifyListeners();
    }
  }

  Future<void> fetchQuotationDetail(String id, String token) async {
    _isDetailLoading = true;
    _detailError = null;
    _selectedQuotation = null;
    notifyListeners();

    try {
      _selectedQuotation = await _quotationRepository.fetchQuotationDetail(
        id,
        token,
      );
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitQuotation(
    SalesQuotationPostModel quotationData,
    String token,
  ) async {
    _isSubmitting = true;
    _submitError = null;
    _lastCreatedQuotationId = null;
    notifyListeners();

    try {
      final response = await _quotationRepository.submitQuotation(
        quotationData,
        token,
      );

      // Parse the response to get the quotation ID
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data') && responseData['data'] is Map) {
        _lastCreatedQuotationId = responseData['data']['id']?.toString();
      } else if (responseData.containsKey('id')) {
        _lastCreatedQuotationId = responseData['id']?.toString();
      }

      _isSubmitting = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _submitError = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false; // Failure
    }
  }

  Future<bool> requestApproval({
    required String authUserId,
    required String salesQuotationId,
    required String token,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _quotationRepository.requestApproval(
        authUserId: authUserId,
        salesQuotationId: salesQuotationId,
        token: token,
      );
      _isSubmitting = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _submitError = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false; // Failure
    }
  }

  Future<bool> updateQuotation(
    String quotationId,
    SalesQuotationPostModel quotationData,
    String token,
  ) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _quotationRepository.updateQuotation(
        quotationId,
        quotationData,
        token,
      );
      _isSubmitting = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _submitError = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false; // Failure
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
