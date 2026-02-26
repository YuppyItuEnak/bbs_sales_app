import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/item/item_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/item/presentation/providers/item_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailItemPage extends StatelessWidget {
  final ItemModel product;

  const DetailItemPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemDetailProvider()..setInitialData(product),
      child: _DetailItemContent(productId: product.id),
    );
  }
}

class _DetailItemContent extends StatefulWidget {
  final String productId;
  const _DetailItemContent({required this.productId});

  @override
  State<_DetailItemContent> createState() => _DetailItemContentState();
}

class _DetailItemContentState extends State<_DetailItemContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final detailProvider = Provider.of<ItemDetailProvider>(
        context,
        listen: false,
      );

      if (authProvider.token != null) {
        detailProvider.fetchItemDetail(
          token: authProvider.token!,
          id: widget.productId,
        );

        final prefs = await SharedPreferences.getInstance();
        final unitBusinessId = prefs.getString('unit_bussiness_id');
        if (unitBusinessId != null) {
          detailProvider.fetchStock(
            token: authProvider.token!,
            itemId: widget.productId,
            unitBusinessId: unitBusinessId,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Detail Item',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Consumer<ItemDetailProvider>(
          builder: (context, provider, child) {
            final product = provider.item!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: product.photo != null
                        ? Image.network(
                            '${ApiConstants.baseUrl2}/${product.photo!}',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.code,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Tersedia ${provider.stockOnHand} PCS",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Spesifikasi Produk",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (provider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...product.specs.entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(child: Text(e.key)),
                                  Text(
                                    e.value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
