import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/dokumen/add_dokumen_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/item_fav/list_item_fav_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class CustomerDocumentPage extends StatelessWidget {
  const CustomerDocumentPage({super.key});

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
            // --- Stepper (Progress Bar) - Tahap 4 Aktif ---
            _buildStepper(),

            // --- Header List ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detail Dokumen",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddDocumentPage(),
                      ),
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

            // --- Document List ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: form.draft.documents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final e = form.draft.documents[index];
                  return _buildDocumentCard(e, form);
                },
              ),
            ),

            // --- Bottom Action Buttons ---
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
          bool isPassed = index < 4; // Tahap 1, 2, 3, dan 4 aktif (biru)
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

  Widget _buildDocumentCard(dynamic e, CustomerFormProvider form) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  e.type,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  e.note ?? "Catatan",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            // Simulasi tombol Edit & Delete seperti di SS
            Container(width: 1, color: Colors.grey.shade200),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
            Container(
              width: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFE54335),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: IconButton(
                onPressed: () => form.removeDocument(e.id),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
              ),
            ),
          ],
        ),
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
                  MaterialPageRoute(
                    builder: (_) => const CustomerFavoriteItemPage(),
                  ),
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
              onPressed: () {
                if (form.draft.addresses.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Mohon tambah data Dokumen terlebih dahulu",
                      ),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerFavoriteItemPage(),
                  ),
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
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
