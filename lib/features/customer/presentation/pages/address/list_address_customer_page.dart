import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/address/add_address_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/rekening/list_rekening_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class CustomerAddressPage extends StatelessWidget {
  const CustomerAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CustomerFormProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Create Customer',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildStepper(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detail Alamat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddAddressPage()),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Tambah"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),

            // --- Address List ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: form.draft.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final e = form.draft.addresses[index];
                  return _buildAddressCard(context, e, form);
                },
              ),
            ),

            // --- Bottom Buttons ---
            _buildBottomButtons(context, form),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(7, (index) {
          bool isPassed = index < 2; // Indeks 0 dan 1 aktif (biru)
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

  Widget _buildAddressCard(
    BuildContext context,
    dynamic e,
    CustomerFormProvider form,
  ) {
    return Dismissible(
      key: Key(e.id.toString()),
      direction: DismissDirection.endToStart,
      background: _buildActionBackground(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.label.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              e.fullAddress,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip("Aktif", const Color(0xFF6366F1)),
                if (e.isDefault) ...[
                  const SizedBox(width: 8),
                  _buildStatusChip("Default", const Color(0xFF4CAF50)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildActionBackground() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit, color: Colors.black54),
          const SizedBox(width: 20),
          Container(
            width: 60,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE54335),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, CustomerFormProvider form) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerBankPage()),
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
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (form.draft.addresses.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mohon tambah data Alamat terlebih dahulu"),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerBankPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Lanjut",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
