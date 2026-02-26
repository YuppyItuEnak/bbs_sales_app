import 'package:bbs_sales_app/data/models/customer/customer_model.dart';
import 'package:bbs_sales_app/data/services/customer/customer_repository.dart';
import 'package:flutter/material.dart';

class CustomerListProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository = CustomerRepository();

  final String? _token;
  final String? _salesId;
  final String? _unitBusinessId;

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CustomerListProvider({
    required String? token,
    required String? salesId,
    required String? unitBusinessId,
  })  : _token = token,
        _salesId = salesId,
        _unitBusinessId = unitBusinessId;

  Future<void> fetchCustomersList() async {
    if (_token == null || _salesId == null || _unitBusinessId == null) {
      _errorMessage = "Authentication details not found.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _customerRepository.fetchCustomers(
        _salesId!,
        _token!,
        unitBusinessId: _unitBusinessId!,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
