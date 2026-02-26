import 'package:bbs_sales_app/data/models/general/performance_target_model.dart';
import 'package:bbs_sales_app/data/models/sales_invoice/sales_target_model.dart';
import 'package:bbs_sales_app/data/services/general/m_gen_repository.dart';
import 'package:bbs_sales_app/data/services/sales_invoice/sales_invoice_repository.dart';
import 'package:flutter/material.dart';

class PerformanceProvider extends ChangeNotifier {
  final SalesInvoiceRepository _salesRepository = SalesInvoiceRepository();
  final MGenRepository _mGenRepository = MGenRepository();

  // Sales target data (Omset)
  SalesTargetDataModel? _salesTargetData;
  bool _isLoadingSalesTarget = false;
  String? _salesTargetError;

  // Visit target data
  PerformanceTargetDataModel? _visitTargetData;
  bool _isLoadingVisitTarget = false;
  String? _visitTargetError;

  // Customer target data
  PerformanceTargetDataModel? _customerTargetData;
  bool _isLoadingCustomerTarget = false;
  String? _customerTargetError;

  // Year selection
  int _selectedYear = DateTime.now().year;
  List<int> _yearOptions = List.generate(
    5,
    (index) => DateTime.now().year - 2 + index,
  );

  // Month selection
  int _selectedMonthIndex = DateTime.now().month - 1; // 0-indexed
  final List<String> _monthOptions = const [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  // Getters
  SalesTargetDataModel? get salesTargetData => _salesTargetData;
  bool get isLoadingSalesTarget => _isLoadingSalesTarget;
  String? get salesTargetError => _salesTargetError;

  PerformanceTargetDataModel? get visitTargetData => _visitTargetData;
  bool get isLoadingVisitTarget => _isLoadingVisitTarget;
  String? get visitTargetError => _visitTargetError;

  PerformanceTargetDataModel? get customerTargetData => _customerTargetData;
  bool get isLoadingCustomerTarget => _isLoadingCustomerTarget;
  String? get customerTargetError => _customerTargetError;

  int get selectedYear => _selectedYear;
  List<int> get yearOptions => _yearOptions;

  int get selectedMonthIndex => _selectedMonthIndex;
  String get selectedMonthName => _monthOptions[_selectedMonthIndex];
  List<String> get monthOptions => _monthOptions;

  // Get month data helper methods
  SalesTargetMonthModel? getCurrentMonthSalesData() {
    if (_salesTargetData == null) return null;
    final monthIndex = _selectedMonthIndex;
    if (monthIndex >= 0 && monthIndex < _salesTargetData!.months.length) {
      return _salesTargetData!.months[monthIndex];
    }
    return null;
  }

  PerformanceTargetMonthModel? getCurrentMonthVisitData() {
    if (_visitTargetData == null) return null;
    final monthIndex = _selectedMonthIndex;
    if (monthIndex >= 0 && monthIndex < _visitTargetData!.months.length) {
      return _visitTargetData!.months[monthIndex];
    }
    return null;
  }

  PerformanceTargetMonthModel? getCurrentMonthCustomerData() {
    if (_customerTargetData == null) return null;
    final monthIndex = _selectedMonthIndex;
    if (monthIndex >= 0 && monthIndex < _customerTargetData!.months.length) {
      return _customerTargetData!.months[monthIndex];
    }
    return null;
  }

  // Fetch all performance data
  Future<void> fetchPerformanceData({
    required String token,
    required String salesId,
    int? year,
  }) async {
    final targetYear = year ?? _selectedYear;

    await Future.wait([
      _fetchSalesTargetData(token: token, salesId: salesId, year: targetYear),
      _fetchVisitTargetData(token: token, salesId: salesId, year: targetYear),
      _fetchCustomerTargetData(
        token: token,
        salesId: salesId,
        year: targetYear,
      ),
    ]);
  }

  Future<void> _fetchSalesTargetData({
    required String token,
    required String salesId,
    required int year,
  }) async {
    _isLoadingSalesTarget = true;
    _salesTargetError = null;
    notifyListeners();

    try {
      final response = await _salesRepository.fetchSalesTargetComparison(
        token: token,
        salesId: salesId,
        year: year,
      );
      _salesTargetData = response.data;
    } catch (e) {
      _salesTargetError = e.toString();
    } finally {
      _isLoadingSalesTarget = false;
      notifyListeners();
    }
  }

  Future<void> _fetchVisitTargetData({
    required String token,
    required String salesId,
    required int year,
  }) async {
    _isLoadingVisitTarget = true;
    _visitTargetError = null;
    notifyListeners();

    try {
      final response = await _mGenRepository.fetchVisitTargetComparison(
        token: token,
        salesId: salesId,
        year: year,
      );
      _visitTargetData = response;
    } catch (e) {
      _visitTargetError = e.toString();
    } finally {
      _isLoadingVisitTarget = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCustomerTargetData({
    required String token,
    required String salesId,
    required int year,
  }) async {
    _isLoadingCustomerTarget = true;
    _customerTargetError = null;
    notifyListeners();

    try {
      final response = await _mGenRepository.fetchCustomerTargetComparison(
        token: token,
        salesId: salesId,
        year: year,
      );
      _customerTargetData = response;
    } catch (e) {
      _customerTargetError = e.toString();
    } finally {
      _isLoadingCustomerTarget = false;
      notifyListeners();
    }
  }

  void setYear(int year, {required String token, required String salesId}) {
    _selectedYear = year;
    notifyListeners();
    fetchPerformanceData(token: token, salesId: salesId, year: year);
  }

  void setMonth(int monthIndex) {
    if (monthIndex >= 0 && monthIndex < _monthOptions.length) {
      _selectedMonthIndex = monthIndex;
      notifyListeners();
    }
  }
}
