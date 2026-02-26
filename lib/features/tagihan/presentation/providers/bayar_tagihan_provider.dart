import 'dart:async';
import 'dart:io';

import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/invoice_detail_model.dart';
import 'package:bbs_sales_app/data/services/tagihan/tagihan_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class BayarTagihanProvider with ChangeNotifier {
  final TagihanRepository _tagihanRepository = TagihanRepository();
  final AuthProvider authProvider;

  BayarTagihanProvider(this.authProvider);

  // Loading and error state
  bool _isLoading = false;
  String? _error;

  // Dropdown lists
  List<MGenModel> _paymentMethods = [];
  List<MGenModel> _reasons = [];

  // Selected values
  String? _selectedPaymentMethod;
  String? _selectedReason;

  // Image state
  File? _pickedImage;

  // Form state
  String _note = '';

  // Location state
  Position? _currentPosition;
  String? _currentAddress;

  // Time state
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MGenModel> get paymentMethods => _paymentMethods;
  List<MGenModel> get reasons => _reasons;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  String? get selectedReason => _selectedReason;
  File? get pickedImage => _pickedImage;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  DateTime get currentTime => _currentTime;

  // Initial data fetching
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([fetchDropdownData(), getCurrentLocation()]);
    startTimer();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDropdownData() async {
    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception("User not authenticated");
      }
      final results = await Future.wait([
        _tagihanRepository.getGenData(token: token, group: 'payment_method'),
        _tagihanRepository.getGenData(
          token: token,
          group: 'REASON_INVOICE_BILLING_SCHEDULE',
        ),
      ]);
      _paymentMethods = results[0];
      _reasons = results[1];
    } catch (e) {
      _error = e.toString();
    }
  }

  // Location methods
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      await _getAddressFromLatLng();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> _getAddressFromLatLng() async {
    if (_currentPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];
      _currentAddress =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
    } catch (e) {
      _error = "Failed to get address: $e";
    }
  }

  // Image picking
  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        _pickedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to pick image: $e";
      notifyListeners();
    }
  }

  // Time methods
  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  // Setters for dropdowns
  void setPaymentMethod(String? value) {
    _selectedPaymentMethod = value;
    notifyListeners();
  }

  void setReason(String? value) {
    _selectedReason = value;
    notifyListeners();
  }

  void setNote(String value) {
    _note = value;
    notifyListeners();
  }

  Future<void> submitPayment({
    required String billingScheduleCustId,
    required List<InvoiceItem> selectedInvoices,
    required List<InvoiceItem> allInvoices,
    required double totalPayment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception("User not authenticated");
      }

      // Upload file first if exists
      String? uploadedFilePath;
      if (_pickedImage != null) {
        uploadedFilePath = await _tagihanRepository.uploadFile(
          token: token,
          file: _pickedImage!,
        );
      }

      // Prepare payload
      final payload = {
        'status': null, // will be set based on logic
        'note': _note.isNotEmpty ? _note : null,
        'file': uploadedFilePath, // uploaded file path in parent
        'total_payment': totalPayment,
        'payment_method': _selectedPaymentMethod,
        'alasan': _selectedReason,
        'lat': _currentPosition?.latitude.toString(),
        'long': _currentPosition?.longitude.toString(),
        'address': _currentAddress,
        'payment_date': DateTime.now().toIso8601String(),
        't_invoice_billing_schedule_cust_ds': allInvoices.map((invoice) {
          final isSelected = selectedInvoices.any(
            (selected) => selected.id == invoice.id,
          );
          final paymentAmount = isSelected
              ? invoice.tSalesInvoice.grandTotal
              : 0.0;
          final status = paymentAmount == invoice.tSalesInvoice.grandTotal;

          return {
            'invoice_id': invoice.invoiceId,
            'status': status,
            'total_payment': paymentAmount,
            'lat': _currentPosition?.latitude.toString(),
            'long': _currentPosition?.longitude.toString(),
            'address': _currentAddress,
            'payment_date': DateTime.now().toIso8601String(),
            'file': status
                ? uploadedFilePath
                : null, // file only in paid children
          };
        }).toList(),
      };

      // Set parent status if all invoices are paid
      final invoiceList =
          payload['t_invoice_billing_schedule_cust_ds'] as List<dynamic>?;
      final allInvoicesPaid =
          invoiceList?.every((invoice) => invoice['status'] == true) ?? false;
      payload['status'] = allInvoicesPaid;

      await _tagihanRepository.submitPayment(
        token: token,
        billingScheduleCustId: billingScheduleCustId,
        payload: payload,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
