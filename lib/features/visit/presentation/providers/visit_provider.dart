import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_non_model.dart';
import 'package:bbs_sales_app/data/services/visit/visit_repository.dart';
import 'package:flutter/material.dart';

class VisitProvider with ChangeNotifier {
  final VisitRepository _visitRepository = VisitRepository();

  List<VisitSalesNonProspectDetail> _visits = [];
  List<VisitSalesNonProspectDetail> get visits => _visits;
  List<VisitSalesDetail> _visitsPros = [];
  List<VisitSalesDetail> get visitsPros => _visitsPros;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;

  bool _hasOpenVisitWithoutCustomer = false;
  bool get hasOpenVisitWithoutCustomer => _hasOpenVisitWithoutCustomer;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  Future<void> fetchVisits(String salesId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _visitsPros = await _visitRepository.fetchVisits(
        salesId,
        token,
        search: _searchKeyword,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVisitsNonProspect(String salesId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _visits = await _visitRepository.fetchVisitsNonProspect(
        salesId,
        token,
        search: _searchKeyword,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkOpenVisitWithoutCustomer(
    String salesId,
    String token,
  ) async {
    try {
      final response = await _visitRepository.checkOpenVisitWithoutCustomer(
        salesId,
        token,
      );
      _hasOpenVisitWithoutCustomer = !(response['valid'] as bool? ?? true);
    } catch (e) {
      _error = e.toString();
      _hasOpenVisitWithoutCustomer = false;
    }
    notifyListeners();
  }
}
