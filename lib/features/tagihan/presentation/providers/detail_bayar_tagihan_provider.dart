import 'package:bbs_sales_app/data/models/tagihan/payment_detail_model.dart';
import 'package:bbs_sales_app/data/services/tagihan/tagihan_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class DetailBayarTagihanProvider with ChangeNotifier {
  final TagihanRepository _tagihanRepository = TagihanRepository();
  final AuthProvider authProvider;

  DetailBayarTagihanProvider(this.authProvider);

  bool _isLoading = false;
  String? _error;
  PaymentDetailModel? _paymentDetail;

  bool get isLoading => _isLoading;
  String? get error => _error;
  PaymentDetailModel? get paymentDetail => _paymentDetail;

  Future<void> fetchPaymentDetail({required String id}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception("User not authenticated");
      }

      _paymentDetail = await _tagihanRepository.getPaymentDetail(
        token: token,
        id: id,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
