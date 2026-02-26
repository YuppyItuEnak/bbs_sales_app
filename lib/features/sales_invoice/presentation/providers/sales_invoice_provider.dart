import 'package:bbs_sales_app/data/models/sales_invoice/sales_invoice_model.dart';
import 'package:bbs_sales_app/data/services/sales_invoice/sales_invoice_repository.dart';
import 'package:flutter/material.dart';

class SalesInvoiceProvider extends ChangeNotifier {
  final SalesInvoiceRepository _repository = SalesInvoiceRepository();

  List<SalesInvoiceModel> _salesInvoices = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SalesInvoiceModel> get salesInvoices => _salesInvoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSalesInvoices({
    required String token,
    required String customerId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salesInvoices = await _repository.fetchSalesInvoices(
        token: token,
        customerId: customerId,
      );
    } catch (e) {
      _error = e.toString();
      _salesInvoices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // You might want to add a method to clear the list or a single selected invoice
  void clearSalesInvoices() {
    _salesInvoices = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
