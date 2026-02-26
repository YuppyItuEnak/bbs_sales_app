import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/services/general/m_gen_repository.dart';
import 'package:flutter/material.dart';

class PpnProvider with ChangeNotifier {
  final MGenRepository _mGenRepository = MGenRepository();
  List<MGenModel> _ppnOptions = [];
  bool _isLoading = false;
  String? _error;

  List<MGenModel> get ppnOptions => _ppnOptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPpnOptions(String token) async {
    _isLoading = true;
    _error = null;

    try {
      _ppnOptions = await _mGenRepository.fetchMGen('group=m_ppn', token);
    } catch (e) {
      _error = 'Failed to fetch PPN options: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
