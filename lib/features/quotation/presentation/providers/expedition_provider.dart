import 'package:bbs_sales_app/data/models/expedition/expedition_model.dart';
import 'package:bbs_sales_app/data/services/general/expedition_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpeditionProvider with ChangeNotifier {
  final ExpeditionRepository _expeditionRepository = ExpeditionRepository();
  List<ExpeditionModel> _expeditions = [];
  bool _isLoading = false;
  String? _error;

  List<ExpeditionModel> get expeditions => _expeditions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExpeditions(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final unitBusinessId = prefs.getString('unit_bussiness_id');

    try {
      _expeditions = await _expeditionRepository.fetchExpeditions(
        token,
        unitBusinessId!,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch expeditions: $e';
      notifyListeners();
    }
  }
}
