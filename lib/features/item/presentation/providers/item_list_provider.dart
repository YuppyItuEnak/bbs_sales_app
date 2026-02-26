import 'package:bbs_sales_app/data/models/item/item_model.dart';
import 'package:bbs_sales_app/data/services/item/item_repository.dart';
import 'package:flutter/material.dart';

class ItemListProvider extends ChangeNotifier {
  final ItemRepository _itemRepository = ItemRepository();
  List<ItemModel> _items = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  final int _paginateLimit = 50; // Define paginate limit

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get page => _page;

  Future<void> fetchItems({
    required String token,
    String? search,
    String? itemDivisionId,
    bool isRefresh = false, // Added parameter to differentiate refresh from load more
  }) async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (isRefresh) {
        _page = 1;
        _items = [];
        _hasMore = true;
      }

      final fetchedItems = await _itemRepository.fetchItems(
        token: token,
        search: search,
        itemDivisionId: itemDivisionId,
        paginate: _paginateLimit,
        page: _page, // Pass the current page
      );

      if (fetchedItems.isNotEmpty) {
        _items.addAll(fetchedItems);
        _hasMore = fetchedItems.length == _paginateLimit;
      } else {
        _hasMore = false;
      }
      _page++; // Increment page for the next fetch
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetPagination() {
    _page = 1;
    _hasMore = true;
    _items = [];
    _error = null;
    notifyListeners();
  }

  void clearItems() {
    _items = [];
    notifyListeners();
  }
}
