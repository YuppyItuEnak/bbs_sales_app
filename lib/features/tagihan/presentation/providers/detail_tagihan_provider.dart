import 'package:bbs_sales_app/data/models/tagihan/billing_history_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/receivable_summary_model.dart';
import 'package:bbs_sales_app/data/services/tagihan/tagihan_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class DetailTagihanProvider with ChangeNotifier {
  final TagihanRepository _tagihanRepository = TagihanRepository();
  final AuthProvider authProvider;

  DetailTagihanProvider(this.authProvider);

  bool _isLoading = false;
  ReceivableSummary? _summary;
  List<BillingHistory> _history = [];
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  ReceivableSummary? get summary => _summary;
  List<BillingHistory> get history => _history;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchDetailTagihan({
    required String customerId,
    required String startDate,
    required String endDate,
  }) async {
    _isLoading = true;
    _error = null;
    _page = 1;
    _history = [];
    _hasMore = true;
    notifyListeners();

    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception("User not authenticated");
      }

      _summary = await _tagihanRepository.getReceivableSummary(
        token: token,
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
      );

      final historyData = await _tagihanRepository.getBillingHistory(
        token: token,
        customerId: customerId,
        page: _page,
      );
      _history.addAll(historyData);
      if (historyData.length < 10) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(String customerId) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _page++;
    notifyListeners();

    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception("User not authenticated");
      }

      final historyData = await _tagihanRepository.getBillingHistory(
        token: token,
        customerId: customerId,
        page: _page,
      );
      _history.addAll(historyData);
      if (historyData.length < 10) {
        _hasMore = false;
      }
    } catch (e) {
      // Handle error, maybe log it or show a toast
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
