import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/restriction/restriction_customer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/item_fav/add_item_fav_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class CustomerFavoriteItemPage extends StatelessWidget {
  const CustomerFavoriteItemPage({super.key});

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
            // --- Stepper (Progress Bar) - Tahap 5 Aktif ---
            _buildStepper(),

            // --- Header List ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detail Item Favorite",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PickItemPage()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Tambah"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),

            // --- Favorite Item List ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: form.draft.favoriteItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final e = form.draft.favoriteItems[index];
                  return _buildItemCard(e, form);
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
          // Tahap 1 sampai 5 aktif (biru)
          bool isPassed = index < 5;
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

  Widget _buildItemCard(dynamic item, CustomerFormProvider form) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Placeholder Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://via.placeholder.com/50",
                ), // Ganti dengan item.imageUrl jika ada
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Deskripsi item...",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => form.removeFavorite(item.id),
            icon: const Icon(Icons.star, color: Colors.amber),
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
                  MaterialPageRoute(
                    builder: (_) => const CustomerRestrictionPage(),
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
                if (form.draft.favoriteItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Mohon tambah data Item Favorite terlebih dahulu",
                      ),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerRestrictionPage(),
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
