import 'package:bbs_sales_app/data/models/item/item_model.dart';
import 'package:bbs_sales_app/data/services/item/item_repository.dart';
import 'package:flutter/material.dart';

class ItemDetailProvider with ChangeNotifier {
  final ItemRepository _itemRepository = ItemRepository();
  ItemModel? _item;
  double _stockOnHand = 0.0;
  bool _isLoading = false;
  String? _error;

  ItemModel? get item => _item;
  double get stockOnHand => _stockOnHand;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setInitialData(ItemModel item) {
    _item = item;
  }

  Future<void> fetchItemDetail({
    required String token,
    required String id,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final item = await _itemRepository.fetchItemDetail(token: token, id: id);
      _item = item;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStock({
    required String token,
    required String itemId,
    required String unitBusinessId,
  }) async {
    try {
      final stock = await _itemRepository.fetchStockOnHand(
        token: token,
        itemId: itemId,
        unitBusinessId: unitBusinessId,
      );
      _stockOnHand = stock;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching stock: $e');
    }
  }
}
