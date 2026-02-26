import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class ContactTile extends StatefulWidget {
  final dynamic data; // Sesuaikan tipe data asli (CustomerContactModel)
  final int index;

  const ContactTile({super.key, required this.data, required this.index});

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  bool isExpanded = false;

  // Controller agar text tidak hilang saat rebuild
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.data.name);
    phoneCtrl = TextEditingController(text: widget.data.phone);
    // Expand otomatis item pertama
    if (widget.index == 1) isExpanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final form = context.read<CustomerFormProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF), // Warna background header
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // --- Header Accordion ---
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Phone Number ${widget.index}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // --- Expanded Content ---
          if (isExpanded)
            Container(
              color: Colors.white, // Background putih untuk form
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Hapus di kanan atas
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => form.removeContact(widget.data.id),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Hapus",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildLabel("Name"),
                  _buildTextField(
                    nameCtrl,
                    "Nama Lengkap",
                    (v) => form.updateContact(widget.data.id, name: v),
                  ),

                  const SizedBox(height: 16),

                  _buildLabel("Phone Number"),
                  _buildTextField(
                    phoneCtrl,
                    "08123456789",
                    (v) => form.updateContact(widget.data.id, phone: v),
                    isPhone: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: const [
            TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    Function(String) onChanged, {
    bool isPhone = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFBFBFB), // Background abu-abu muda
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}
