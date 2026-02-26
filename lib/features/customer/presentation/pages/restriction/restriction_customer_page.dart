import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/contact/contact_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class CustomerRestrictionPage extends StatelessWidget {
  const CustomerRestrictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CustomerFormProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text("Customer", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- Stepper (Progress Bar) - Tahap 6 Aktif ---
          _buildStepper(),

          // --- Header ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detail Restriction",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // --- List Checkboxes ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCheckboxTile(
                  "Sales Quotation",
                  form.draft.allowQuotation,
                  (v) => form.setRestriction(quotation: v),
                ),
                _buildCheckboxTile(
                  "Sales Order",
                  form.draft.allowOrder,
                  (v) => form.setRestriction(order: v),
                ),
                _buildCheckboxTile(
                  "Delivery Order",
                  form.draft.allowDelivery,
                  (v) => form.setRestriction(delivery: v),
                ),
                _buildCheckboxTile(
                  "Sales Invoice",
                  form.draft.allowInvoice,
                  (v) => form.setRestriction(invoice: v),
                ),
                _buildCheckboxTile(
                  "Sales Retur",
                  form.draft.allowReturn,
                  (v) => form.setRestriction(returned: v),
                ),
              ],
            ),
          ),

          // --- Bottom Buttons ---
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(7, (index) {
          bool isPassed = index < 6; // Tahap 1-6 aktif (biru)
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPassed ? const Color(0xFF6366F1) : Colors.white,
                    border: Border.all(
                      color: isPassed
                          ? const Color(0xFF6366F1)
                          : Colors.blue.shade100,
                      width: 2,
                    ),
                  ),
                  child: isPassed
                      ? const Icon(Icons.circle, size: 12, color: Colors.white)
                      : null,
                ),
                if (index != 6)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPassed
                          ? const Color(0xFF6366F1)
                          : Colors.blue.shade100,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCheckboxTile(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF), // Warna background tipis
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        activeColor: const Color(0xFF6366F1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        controlAffinity: ListTileControlAffinity.leading, // Checkbox di kiri
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerPhonePage()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF6366F1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Lewati",
                style: TextStyle(color: Color(0xFF6366F1), fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerPhonePage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Lanjut",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
