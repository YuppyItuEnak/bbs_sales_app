import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/detail_customer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/widgets/contact_tile_widget.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';
// import ke detail page akhir jika ada

class CustomerPhonePage extends StatelessWidget {
  const CustomerPhonePage({super.key});

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
            // --- Stepper (Progress Bar) - Tahap 7 (Full) Aktif ---
            _buildStepper(),

            // --- Header Row ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detail No. Telepon",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => form.addContact(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Tambah"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),

            // --- Contact List ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: form.draft.contacts.length,
                itemBuilder: (context, index) {
                  final e = form.draft.contacts[index];
                  // Kirim index agar title bisa "Phone Number 1", "Phone Number 2"
                  return ContactTile(data: e, index: index + 1);
                },
              ),
            ),

            // --- Bottom Buttons ---
            _buildBottomButtons(context),
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
          bool isPassed = true; // Semua aktif di tahap terakhir
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
                  MaterialPageRoute(builder: (_) => const CustomerDetailPage()),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerDetailPage()),
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
