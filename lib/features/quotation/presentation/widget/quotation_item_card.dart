import 'package:bbs_sales_app/data/models/item/selected_item_model.dart';
import 'package:bbs_sales_app/features/quotation/presentation/pages/quotation_form_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuotationItemCard extends StatefulWidget {
  final SelectedItem item;
  final String? customerSegment;
  final double displaySubtotal;
  final bool isPpnIncluded;
  final PriceBelowWarning warning;
  final Function(int) onQuantityChanged;
  final Function(double, double) onDiscountChanged;
  final VoidCallback onDelete;

  const QuotationItemCard({
    super.key,
    required this.item,
    required this.customerSegment,
    required this.displaySubtotal,
    required this.isPpnIncluded,
    required this.warning,
    required this.onQuantityChanged,
    required this.onDiscountChanged,
    required this.onDelete,
  });

  @override
  State<QuotationItemCard> createState() => _QuotationItemCardState();
}

class _QuotationItemCardState extends State<QuotationItemCard> {
  bool _expanded = false;
  late TextEditingController _quantityController;
  late TextEditingController _discountPercentController;
  late TextEditingController _discountValueController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _discountPercentController = TextEditingController(
      text: widget.item.discountPercent.toStringAsFixed(0),
    );
    _discountValueController = TextEditingController(
      text: widget.item.discountValue.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(QuotationItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.quantity != oldWidget.item.quantity &&
        !_quantityController.value.composing.isValid) {
      _quantityController.text = widget.item.quantity.toString();
    }
    if (widget.item.discountPercent != oldWidget.item.discountPercent &&
        !_discountPercentController.value.composing.isValid) {
      _discountPercentController.text = widget.item.discountPercent
          .toStringAsFixed(0);
    }
    if (widget.item.discountValue != oldWidget.item.discountValue &&
        !_discountValueController.value.composing.isValid) {
      _discountValueController.text = widget.item.discountValue.toStringAsFixed(
        0,
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountPercentController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  String _format(num value) {
    final format = NumberFormat.decimalPattern('id_ID');
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final displayPricePerUnit = widget.displaySubtotal / widget.item.quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded ? const Color(0xFF2F80ED) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.item.item.code,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              InkWell(
                onTap: widget.onDelete,
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.item.item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          if (!_expanded) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sub Total'),
                Row(
                  children: [
                    Text(
                      'Rp ${_format(widget.displaySubtotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => setState(() => _expanded = true),
                      child: const Icon(Icons.expand_more),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.warning == PriceBelowWarning.below)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '*Harga dibawah pricelist',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            if (widget.warning == PriceBelowWarning.belowTenPercent)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '*Harga dibawah 10% dari pricelist!',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ] else ...[
            Row(
              children: [
                _InputBox(
                  label: 'Price',
                  flex: 2,
                  child: Text(
                    'Rp ${_format(displayPricePerUnit)} / ${widget.item.item.uom ?? ''}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                _InputBox(
                  label: 'Qty',
                  flex: 1,
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final newQuantity = int.tryParse(val) ?? 0;
                      if (newQuantity != widget.item.quantity) {
                        widget.onQuantityChanged(newQuantity);
                      }
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InputBox(
                  label: 'Disc %',
                  child: TextField(
                    controller: _discountPercentController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final percent = double.tryParse(val) ?? 0.0;
                      final currentValue =
                          double.tryParse(_discountValueController.text) ?? 0.0;
                      widget.onDiscountChanged(percent, currentValue);
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      suffixText: '%',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _InputBox(
                  label: 'Disc Rp',
                  child: TextField(
                    controller: _discountValueController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final value = double.tryParse(val) ?? 0.0;
                      final currentPercent =
                          double.tryParse(_discountPercentController.text) ??
                          0.0;
                      widget.onDiscountChanged(currentPercent, value);
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sub Total'),
                Row(
                  children: [
                    Text(
                      'Rp ${_format(widget.displaySubtotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => setState(() => _expanded = false),
                      child: const Icon(Icons.expand_less),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String label;
  final Widget child;
  final int flex;
  final double? width;

  const _InputBox({
    required this.label,
    required this.child,
    this.flex = 1,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: const BoxConstraints(minHeight: 45),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: content);
    }

    return Expanded(flex: flex, child: content);
  }
}
