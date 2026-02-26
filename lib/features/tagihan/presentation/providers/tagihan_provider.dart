import 'package:bbs_sales_app/data/models/tagihan/customer_billing_model.dart';
import 'package:bbs_sales_app/data/services/tagihan/tagihan_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class TagihanProvider with ChangeNotifier {
  final TagihanRepository _tagihanRepository = TagihanRepository();
  final AuthProvider authProvider;

  TagihanProvider(this.authProvider);

  bool _isLoading = false;
  List<CustomerBilling> _customerBillings = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<CustomerBilling> get customerBillings => _customerBillings;
  String? get error => _error;

  Future<void> fetchCustomerBillings(String startDate, String endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = authProvider.token;
      final salesId = authProvider.salesId;

      if (token == null || salesId == null) {
        throw Exception("User not authenticated");
      }

      _customerBillings = await _tagihanRepository.getCustomerBilling(
        token: token,
        salesId: salesId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
