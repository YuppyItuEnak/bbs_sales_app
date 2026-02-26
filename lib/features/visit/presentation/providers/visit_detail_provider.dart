import 'dart:convert';

import 'package:bbs_sales_app/data/models/visit/visit_realization_detail_model.dart';
import 'package:bbs_sales_app/data/services/visit/visit_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class VisitDetailProvider with ChangeNotifier {
  final VisitRepository _visitRepository = VisitRepository();

  VisitRealizationDetail? _visitDetail;
  VisitRealizationDetail? get visitDetail => _visitDetail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isWithinRadius = false;
  bool get isWithinRadius => _isWithinRadius;

  String? _radiusCheckMessage;
  String? get radiusCheckMessage => _radiusCheckMessage;

  Future<void> fetchVisitDetail(String realizationId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _visitDetail = await _visitRepository.fetchVisitDetail(
        realizationId,
        token,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> performRadiusCheck({
    required String customerId,
    required Position position,
    required String token,
  }) async {
    _radiusCheckMessage = 'Checking radius...';
    _isWithinRadius = false;
    notifyListeners();
    try {
      final result = await _visitRepository.checkRadius(
        customerId: customerId,
        latitude: position.latitude,
        longitude: position.longitude,
        token: token,
      );

      if (result['status'] == 'success') {
        _isWithinRadius = result['within_5_meter'] ?? false;
        final distance =
            result['distance_in_meter']?.toStringAsFixed(2) ?? 'N/A';
        _radiusCheckMessage = _isWithinRadius
            ? 'Dalam jangkauan. Jarak: $distance meter.'
            : 'Di luar jangkauan. Jarak: $distance meter.';
      } else {
        _radiusCheckMessage = result['message'] ?? 'Gagal memeriksa radius.';
      }
    } catch (e) {
      String errorMessage = e.toString();
      final match = RegExp(
        r'Exception: Failed to check radius: (\{.*\})',
      ).firstMatch(errorMessage);
      if (match != null) {
        try {
          final jsonError = json.decode(match.group(1)!);
          _radiusCheckMessage =
              jsonError['message'] ?? 'Gagal memeriksa radius.';
        } catch (_) {
          _radiusCheckMessage = 'Gagal memeriksa radius (unparseable error).';
        }
      } else {
        _radiusCheckMessage = 'Gagal memeriksa radius.';
      }
    }
    notifyListeners();
  }

  Future<bool> performCheckIn({
    required Map<String, String> data,
    required String photoPath,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDetail = await _visitRepository.checkIn(
        data: data,
        photoPath: photoPath,
        token: token,
      );
      _visitDetail = newDetail;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> performCheckOut({
    required String realizationId,
    required Map<String, String> data,
    required String photoPath,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _visitRepository.checkOut(
        realizationId: realizationId,
        data: data,
        photoPath: photoPath,
        token: token,
      );
      if (success) {
        await fetchVisitDetail(realizationId, token);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
