import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/item/item_model.dart';
import 'package:bbs_sales_app/data/services/item/item_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/item/presentation/pages/detail_item_page.dart';
import 'package:bbs_sales_app/features/item/presentation/providers/item_list_provider.dart';
import 'package:bbs_sales_app/features/item/presentation/widgets/item_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListItemPage extends StatefulWidget {
  const ListItemPage({super.key});

  @override
  State<ListItemPage> createState() => _ListItemPageState();
}

class _ListItemPageState extends State<ListItemPage> {
  final ScrollController _scrollController = ScrollController();
  String? _currentSearchTerm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchItems(isRefresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems({bool isRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemListProvider>(context, listen: false);
    if (authProvider.token != null) {
      await itemProvider.fetchItems(
        token: authProvider.token!,
        search: _currentSearchTerm,
        isRefresh: isRefresh,
      );
    }
  }

  Future<void> _loadMoreItems() async {
    final itemProvider = Provider.of<ItemListProvider>(context, listen: false);
    if (itemProvider.hasMore && !itemProvider.isLoading) {
      await _fetchItems();
    }
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
            'Katalog',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _currentSearchTerm = value;
                    _fetchItems(isRefresh: true);
                  },
                  decoration: const InputDecoration(
                    hintText: "Cari",
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid
              Expanded(
                child: Consumer<ItemListProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            itemCount: provider.items.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                            itemBuilder: (context, index) {
                              final product = provider.items[index];
                              return ItemCard(
                                product: product,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailItemPage(product: product),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (provider.isLoading && provider.items.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
