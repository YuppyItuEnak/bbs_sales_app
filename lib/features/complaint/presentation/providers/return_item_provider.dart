import 'package:bbs_sales_app/data/models/sales_invoice/sales_invoice_model.dart';
import 'package:bbs_sales_app/data/models/sales_invoice/surat_jalan_model.dart';
import 'package:bbs_sales_app/data/services/sales_invoice/sales_invoice_repository.dart';
import 'package:bbs_sales_app/data/services/sales_invoice/surat_jalan_repository.dart';
import 'package:flutter/material.dart';

class ReturnItemProvider extends ChangeNotifier {
  final SalesInvoiceRepository _siRepo = SalesInvoiceRepository();
  final SuratJalanRepository _sjRepo = SuratJalanRepository();

  List<SuratJalanDetailModel> _sjDetails = [];
  List<TSalesInvoiceDsModel> _siDetails = [];
  List<SelectedItem> _selectedItems = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<SuratJalanDetailModel> get sjDetails => _sjDetails;
  List<TSalesInvoiceDsModel> get siDetails => _siDetails;
  List<SelectedItem> get selectedItems => _selectedItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSJDetails({
    required String token,
    required String sjId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sjDetail = await _sjRepo.fetchSuratJalanDetail(
        token: token,
        id: sjId,
      );
      _sjDetails = sjDetail.details;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSIDetails({
    required String token,
    required String siId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final siDetail = await _siRepo.fetchSalesInvoiceDetail(
        token: token,
        id: siId,
      );
      _siDetails = siDetail.tSalesInvoiceDs ?? [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSJItemSelection(SuratJalanDetailModel item, bool selected) {
    if (selected) {
      _selectedItems.add(SelectedItem.fromSJDetail(item));
    } else {
      _selectedItems.removeWhere(
        (selectedItem) => selectedItem.itemId == item.itemId,
      );
    }
    notifyListeners();
  }

  void toggleSIItemSelection(TSalesInvoiceDsModel item, bool selected) {
    if (selected) {
      _selectedItems.add(SelectedItem.fromSIDetail(item));
    } else {
      _selectedItems.removeWhere(
        (selectedItem) => selectedItem.itemId == item.itemId,
      );
    }
    notifyListeners();
  }

  void clearSelections() {
    _selectedItems.clear();
    notifyListeners();
  }
}

class SelectedItem {
  final String? itemId;
  final String? itemName;
  final int? qty;
  final String? uomUnit;
  final int? uomValue;

  SelectedItem({
    this.itemId,
    this.itemName,
    this.qty,
    this.uomUnit,
    this.uomValue,
  });

  factory SelectedItem.fromSJDetail(SuratJalanDetailModel detail) {
    return SelectedItem(
      itemId: detail.itemId,
      itemName: detail.itemName,
      qty: detail.qty,
      uomUnit: detail.uomUnit,
      uomValue: detail.uomValue,
    );
  }

  factory SelectedItem.fromSIDetail(TSalesInvoiceDsModel detail) {
    return SelectedItem(
      itemId: detail.itemId,
      itemName: detail.itemName,
      qty: detail.qtySj,
      uomUnit: detail.uomUnit,
      uomValue: detail.uomValue,
    );
  }
}
