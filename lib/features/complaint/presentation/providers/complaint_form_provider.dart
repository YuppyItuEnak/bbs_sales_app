import 'dart:io';

import 'package:bbs_sales_app/data/models/complaint/complaint_add_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_name_model.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/models/sales_invoice/sales_invoice_model.dart'; // NEW
import 'package:bbs_sales_app/data/models/sales_invoice/surat_jalan_model.dart'; // NEW
import 'package:bbs_sales_app/data/services/complaint/complaint_repository.dart';
import 'package:bbs_sales_app/data/services/customer/customer_repository.dart';
import 'package:bbs_sales_app/data/services/general/m_gen_repository.dart';
import 'package:bbs_sales_app/data/services/sales_invoice/sales_invoice_repository.dart';
import 'package:bbs_sales_app/data/services/sales_invoice/surat_jalan_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ComplaintFormProvider extends ChangeNotifier {
  final CustomerRepository _customerRepo = CustomerRepository();
  final MGenRepository _mGenRepo = MGenRepository();
  final ComplainRepository _complainRepo = ComplainRepository();
  final SalesInvoiceRepository _salesInvoiceRepo = SalesInvoiceRepository();
  final SuratJalanRepository _suratJalanRepo = SuratJalanRepository();

  bool _isLoading = false;
  bool _isLoadingSalesInvoices = false; // NEW
  String? _error;
  String? _salesInvoiceError; // NEW

  List<CustomerSimpleModel> _customers = [];
  List<MGenModel> _complaintTypes = [];
  List<SalesInvoiceModel> _salesInvoices = []; // NEW
  List<SuratJalanModel> _suratJalan = []; // NEW
  SalesInvoiceModel? _selectedSalesInvoice; // NEW
  SuratJalanModel? _selectedSuratJalan; // NEW
  String _selectedRefType = 'SI'; // NEW

  // Form Fields
  CustomerSimpleModel? _selectedCustomer;
  MGenModel? _selectedComplaintType;
  // String? _selectedInvoice; // OLD

  final TextEditingController contactPersonCtrl = TextEditingController();

  // Items
  List<ComplainCreateItemModel> _items = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingSalesInvoices => _isLoadingSalesInvoices; // NEW
  String? get error => _error;
  String? get salesInvoiceError => _salesInvoiceError; // NEW
  List<CustomerSimpleModel> get customers => _customers;
  List<MGenModel> get complaintTypes => _complaintTypes;
  List<SalesInvoiceModel> get salesInvoices => _salesInvoices; // NEW
  List<SuratJalanModel> get suratJalan => _suratJalan; // NEW
  SalesInvoiceModel? get selectedSalesInvoice => _selectedSalesInvoice; // NEW
  SuratJalanModel? get selectedSuratJalan => _selectedSuratJalan; // NEW
  String get selectedRefType => _selectedRefType; // NEW

  CustomerSimpleModel? get selectedCustomer => _selectedCustomer;
  MGenModel? get selectedComplaintType => _selectedComplaintType;
  // String? get selectedInvoice => _selectedInvoice; // OLD
  List<ComplainCreateItemModel> get items => _items;

  Future<void> loadData({
    required String token,
    required String unitBusinessId,
    required String salesId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _customerRepo.fetchListCustomersName(
          token,
          search: '',
          salesId: salesId,
          unitBusinessId: unitBusinessId,
        ),
        _mGenRepo.fetchMGen("group=m_complain_type", token),
      ]);

      _customers = results[0] as List<CustomerSimpleModel>;
      _complaintTypes = results[1] as List<MGenModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCustomer(BuildContext context, CustomerSimpleModel? val) async {
    _selectedCustomer = val;
    _salesInvoices = [];
    _suratJalan = [];
    _selectedSalesInvoice = null;
    _selectedSuratJalan = null;
    _salesInvoiceError = null;
    notifyListeners();

    if (val != null && val.id != null) {
      _isLoadingSalesInvoices = true;
      notifyListeners();

      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        try {
          if (_selectedRefType == 'SI') {
            _salesInvoices = await _salesInvoiceRepo.fetchSalesInvoices(
              token: auth.token!,
              customerId: val.id!,
            );
          } else if (_selectedRefType == 'SJ') {
            _suratJalan = await _suratJalanRepo.fetchSuratJalan(
              token: auth.token!,
              customerId: val.id!,
            );
          }
        } catch (e) {
          _salesInvoiceError = e.toString();
        }
      } else {
        _salesInvoiceError = 'Authentication token is missing.';
      }

      _isLoadingSalesInvoices = false;
      notifyListeners();
    }
  }

  void setComplaintType(MGenModel? val) {
    _selectedComplaintType = val;
    notifyListeners();
  }

  void setSalesInvoice(SalesInvoiceModel? val) {
    _selectedSalesInvoice = val;
    notifyListeners();
  }

  void setSuratJalan(SuratJalanModel? val) {
    _selectedSuratJalan = val;
    notifyListeners();
  }

  Future<void> setRefType(BuildContext context, String val) async {
    _selectedRefType = val;
    // Reset selections when changing type
    _salesInvoices = [];
    _suratJalan = [];
    _selectedSalesInvoice = null;
    _selectedSuratJalan = null;
    _salesInvoiceError = null;
    notifyListeners();

    if (_selectedCustomer != null && _selectedCustomer!.id != null) {
      _isLoadingSalesInvoices = true;
      notifyListeners();

      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        try {
          if (_selectedRefType == 'SI') {
            _salesInvoices = await _salesInvoiceRepo.fetchSalesInvoices(
              token: auth.token!,
              customerId: _selectedCustomer!.id!,
            );
          } else if (_selectedRefType == 'SJ') {
            _suratJalan = await _suratJalanRepo.fetchSuratJalan(
              token: auth.token!,
              customerId: _selectedCustomer!.id!,
            );
          }
        } catch (e) {
          _salesInvoiceError = e.toString();
        }
      } else {
        _salesInvoiceError = 'Authentication token is missing.';
      }

      _isLoadingSalesInvoices = false;
      notifyListeners();
    } else if (_selectedCustomer != null && _selectedCustomer!.id == null) {
      _salesInvoiceError = 'Customer ID is missing.';
      notifyListeners();
    }
  }

  void addItem(ComplainCreateItemModel item) {
    _items.add(item);
    notifyListeners();
  }

  void addItems(List<ComplainCreateItemModel> newItems) {
    _items.addAll(newItems);
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateItemQuantities(
    int index, {
    int? newQtyReturn,
    int? newQtyReplaced,
  }) {
    if (newQtyReturn != null) {
      _items[index].qtyReturn = newQtyReturn;
    }
    if (newQtyReplaced != null) {
      _items[index].qtyReplaced = newQtyReplaced;
    }
    notifyListeners();
  }

  Future<void> pickImageForItem(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _items[index].imageFiles.add(File(image.path));
      notifyListeners();
    }
  }

  void removeImageFromItem(int itemIndex, int imageIndex) {
    _items[itemIndex].imageFiles.removeAt(imageIndex);
    notifyListeners();
  }

  Future<bool> submit({
    required String token,
    required String salesId,
    required String unitBusinessId,
  }) async {
    if (_selectedCustomer == null ||
        _selectedComplaintType == null ||
        (_selectedRefType == 'SI' && _selectedSalesInvoice == null) ||
        (_selectedRefType == 'SJ' && _selectedSuratJalan == null)) {
      // Updated validation
      _error = "Mohon lengkapi data";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = ComplainCreateModel()
        ..customerId = _selectedCustomer!.id
        ..complainTypeId = _selectedComplaintType!.id
        ..salesId = salesId
        ..unitBusinessId = unitBusinessId
        ..date = DateTime.now()
        ..status =
            1 // Draft
        ..notes = contactPersonCtrl.text
        ..items = _items
        ..siId = _selectedRefType == 'SI'
            ? _selectedSalesInvoice!.id
            : _selectedSuratJalan!.id;

      await _complainRepo.createComplaint(token: token, data: data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    contactPersonCtrl.dispose();
    super.dispose();
  }
}
