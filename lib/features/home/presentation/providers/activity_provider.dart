import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_non_model.dart';
import 'package:bbs_sales_app/data/services/visit/activity_repository.dart';
import 'package:flutter/material.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();

  VisitSalesNonProspectDetail? _activity;
  bool _isLoading = false;
  String? _error;

  VisitSalesNonProspectDetail? get activity => _activity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchActivity(String token, String salesId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activity = await _repository.fetchActivity(token, salesId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
