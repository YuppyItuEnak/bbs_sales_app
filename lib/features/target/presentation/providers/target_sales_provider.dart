import 'package:bbs_sales_app/data/models/sales_invoice/sales_target_model.dart';
import 'package:bbs_sales_app/data/services/sales_invoice/sales_invoice_repository.dart';
import 'package:flutter/material.dart';

class TargetSalesProvider extends ChangeNotifier {
  final SalesInvoiceRepository _repository = SalesInvoiceRepository();

  SalesTargetDataModel? _salesTargetData;
  bool _isLoading = false;
  String? _error;
  int _selectedYear = DateTime.now().year;
  List<int> _yearOptions = List.generate(
    5,
    (index) => DateTime.now().year - 2 + index,
  );

  SalesTargetDataModel? get salesTargetData => _salesTargetData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedYear => _selectedYear;
  List<int> get yearOptions => _yearOptions;

  Future<void> fetchSalesTargetComparison({
    required String token,
    required String salesId,
    required int year,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.fetchSalesTargetComparison(
        token: token,
        salesId: salesId,
        year: year,
      );
      _salesTargetData = response.data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setYear(int year, {required String token, required String salesId}) {
    _selectedYear = year;
    notifyListeners();
    fetchSalesTargetComparison(token: token, salesId: salesId, year: year);
  }
}
