import 'package:bbs_sales_app/data/models/item/item_model.dart';

class SelectedItem {
  final ItemModel item;
  int quantity;
  double discountPercent;
  double discountValue;
  double? price;

  SelectedItem({
    required this.item,
    this.quantity = 1,
    this.discountPercent = 0.0,
    this.discountValue = 0.0,
    this.price,
  });
}
