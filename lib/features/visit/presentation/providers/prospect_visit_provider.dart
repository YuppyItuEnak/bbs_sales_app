import 'package:bbs_sales_app/data/services/visit/visit_repository.dart';
import 'package:flutter/material.dart';

class ProspectVisitProvider with ChangeNotifier {
  final VisitRepository _visitRepository = VisitRepository();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  Future<bool> performProspectCheckIn({
    required Map<String, String> data,
    required String photoPath,
    required String token,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _visitRepository.checkIn(
        data: data,
        photoPath: photoPath,
        token: token,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
