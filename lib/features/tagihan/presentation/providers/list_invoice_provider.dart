import 'package:bbs_sales_app/data/models/tagihan/invoice_detail_model.dart';
import 'package:bbs_sales_app/data/services/tagihan/tagihan_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class ListInvoiceProvider with ChangeNotifier {
  final TagihanRepository _tagihanRepository = TagihanRepository();
  final AuthProvider authProvider;

  ListInvoiceProvider(this.authProvider);

  bool _isLoading = false;
  InvoiceDetailModel? _invoiceDetail;
  String? _error;
  final Set<String> _selectedInvoiceIds = {};

  bool get isLoading => _isLoading;
  InvoiceDetailModel? get invoiceDetail => _invoiceDetail;
  String? get error => _error;
  Set<String> get selectedInvoiceIds => _selectedInvoiceIds;

  Future<void> fetchInvoiceDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception("User not authenticated");
      }

      _invoiceDetail = await _tagihanRepository.getInvoiceDetail(
        token: token,
        id: id,
      );

      // By default, all invoices are selected
      _invoiceDetail?.tInvoiceBillingScheduleCustDs.forEach((invoice) {
        _selectedInvoiceIds.add(invoice.id);
      });

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleInvoiceSelection(String invoiceId) {
    if (_selectedInvoiceIds.contains(invoiceId)) {
      _selectedInvoiceIds.remove(invoiceId);
    } else {
      _selectedInvoiceIds.add(invoiceId);
    }
    notifyListeners();
  }

  double get totalSelectedAmount {
    if (_invoiceDetail == null) return 0;

    return _invoiceDetail!.tInvoiceBillingScheduleCustDs
        .where((invoice) => _selectedInvoiceIds.contains(invoice.id))
        .fold(0, (sum, item) => sum + item.tSalesInvoice.grandTotal.toDouble());
  }
}
