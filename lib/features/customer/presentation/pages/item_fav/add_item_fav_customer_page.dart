import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';
import 'package:bbs_sales_app/features/item/presentation/providers/item_list_provider.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';

class PickItemPage extends StatefulWidget {
  const PickItemPage({super.key});

  @override
  State<PickItemPage> createState() => _PickItemPageState();
}

class _PickItemPageState extends State<PickItemPage> {
  // Controller untuk pencarian
  final searchCtrl = TextEditingController();

  // State untuk menyimpan daftar kategori (m_item_division)
  List<MGenModel> categories = [];
  bool isLoadingCategories = true;

  // State untuk melacak kategori mana yang sedang terbuka (Expanded)
  String? expandedCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // 1. Ambil Data Kategori (Divisi Item)
  Future<void> _fetchCategories() async {
    try {
      final form = context.read<CustomerFormProvider>();
      // Pastikan 'm_item_division' adalah key yang benar dari API Anda
      final result = await form.fetchMGenData('m_item_division');
      setState(() {
        categories = result;
        if (categories.isNotEmpty) {
          expandedCategoryId = categories.first.id;
          _fetchItemsForCategory(categories.first.id);
        }
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => isLoadingCategories = false);
    }
  }

  // 2. Ambil Item berdasarkan Kategori yang dipilih
  Future<void> _fetchItemsForCategory(String? itemDivisionId) async {
    if (itemDivisionId == null) return;
    final itemListProvider = context.read<ItemListProvider>();
    itemListProvider.clearItems();

    final form = context.read<CustomerFormProvider>();
    final token = form.token;

    await itemListProvider.fetchItems(
      token: token,
      itemDivisionId: itemDivisionId,
      search: searchCtrl.text,
    );
  }

  void _onCategoryTap(String categoryId) {
    setState(() {
      if (expandedCategoryId == categoryId) {
        expandedCategoryId = null;
      } else {
        expandedCategoryId = categoryId;
        searchCtrl.clear();
        _fetchItemsForCategory(categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemListProvider = context.watch<ItemListProvider>();
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
            'Tambah Item Favorit',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isExpanded = expandedCategoryId == category.id;

                        return Column(
                          children: [
                            // --- Header Kategori (Accordion) ---
                            _buildCategoryHeader(
                              title: category.value1 ?? "Unknown",
                              isExpanded: isExpanded,
                              onTap: () => _onCategoryTap(category.id),
                            ),

                            // --- Isi Kategori (Search Bar & List Item) ---
                            if (isExpanded) ...[
                              const SizedBox(height: 12),
                              // Search Bar
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: searchCtrl,
                                      onChanged: (val) {
                                        // Debounce bisa ditambahkan di sini jika perlu
                                        _fetchItemsForCategory(category.id);
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Cari",
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                        filled: true,
                                        fillColor: const Color(0xFFFBFBFB),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.tune,
                                      size: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Loading State untuk Item
                              if (itemListProvider.isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (itemListProvider.items.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Item tidak ditemukan",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                )
                              else
                                // List Item
                                ...itemListProvider.items.map((item) {
                                  // Cek apakah item sudah ada di draft favorite
                                  final index = form.draft.favoriteItems
                                      .indexWhere(
                                        (fav) => fav.itemId == item.id,
                                      );
                                  bool isSelected = index != -1;

                                  return _buildItemRow(item, isSelected, () {
                                    if (isSelected) {
                                      form.removeFavorite(
                                        form.draft.favoriteItems[index].id!,
                                      );
                                    } else {
                                      form.addFavorite(item);
                                    }
                                  });
                                }),

                              const SizedBox(
                                height: 12,
                              ), // Spacer antar kategori
                            ] else ...[
                              const SizedBox(
                                height: 12,
                              ), // Spacer jika collapsed
                            ],
                          ],
                        );
                      },
                    ),
            ),

            // --- Button Simpan ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Header Accordion (Biru saat expanded, Putih saat collapsed)
  Widget _buildCategoryHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isExpanded
              ? const Color(0xFF6366F1)
              : const Color(0xFFFBFBFB), // Biru vs Abu muda
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isExpanded ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isExpanded ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Baris Item (Thumbnail + Text + Bintang)
  Widget _buildItemRow(dynamic item, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar Item Placeholder (Sesuai SS)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
                // Jika ada URL gambar:
                // image: DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover)
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Teks Item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Subtitle hardcoded sesuai contoh visual, atau ganti item.description
                  Text(
                    "25 Mm X 76 Mm Hollow...",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Tombol Bintang (Toggle Favorite)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                isSelected ? Icons.star : Icons.star_border,
                color: isSelected ? Colors.amber : Colors.grey.shade300,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
