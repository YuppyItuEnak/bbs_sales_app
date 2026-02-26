import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/reimburse/reimburse_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/reimburse/presentation/pages/add_reimburse_page.dart';
import 'package:bbs_sales_app/features/reimburse/presentation/pages/detail_reimburse_page.dart';
import 'package:bbs_sales_app/features/reimburse/presentation/providers/reimburse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReimburseListPage extends StatelessWidget {
  const ReimburseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReimburseProvider(),
      child: const _ReimburseListContent(),
    );
  }
}

class _ReimburseListContent extends StatefulWidget {
  const _ReimburseListContent({super.key});

  @override
  State<_ReimburseListContent> createState() => _ReimburseListContentState();
}

class _ReimburseListContentState extends State<_ReimburseListContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchTerm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = context.read<ReimburseProvider>();
      if (!provider.isLoading && !provider.isFetchingMore && provider.hasMore) {
        _fetchData();
      }
    }
  }

  void _fetchData({bool refresh = false}) {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ReimburseProvider>();

    if (auth.token != null && auth.salesId != null) {
      provider.setSearch(_currentSearchTerm);
      provider.fetch(
        token: auth.token!,
        salesId: auth.salesId!,
        refresh: refresh,
      );
      provider.checkReimburseToday(token: auth.token!, salesId: auth.salesId!);
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
            'Reimburse',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _currentSearchTerm = val;
                  });
                  _fetchData(refresh: true);
                },
                decoration: InputDecoration(
                  hintText: "Cari",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ReimburseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text("Error: ${provider.error}"));
                  }

                  if (provider.items.isEmpty) {
                    return const Center(child: Text("Data tidak ditemukan"));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        provider.items.length +
                        (provider.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final item = provider.items[index];
                      return _buildReimburseTile(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Consumer<ReimburseProvider>(
          builder: (context, provider, child) {
            final reimburseCheck = provider.reimburseCheck;
            bool buttonDisabled = false;
            VoidCallback? onPressedAction = () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddReimbursePage(isEdit: false),
              ),
            );

            if (reimburseCheck != null) {
              if (reimburseCheck.kmAwal != null &&
                  reimburseCheck.kmAkhir != 0) {
                // Kondisi 3: data hari ini lengkap km awal dan akhirnya maka tombol tidak bisa diklik
                buttonDisabled = true;
                onPressedAction = null;
              } else if (reimburseCheck.kmAwal != null &&
                  reimburseCheck.kmAkhir == 0) {
                // Kondisi 2: ada km awal tidak ada km akhir, maka ambil detail reimburse dengan id tersebut
                onPressedAction = () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddReimbursePage(
                      reimburseId: reimburseCheck.id,
                      isEdit: true,
                    ),
                  ),
                );
              }
            }
            // Kondisi 1: tidak ada data di hari ini maka tombol reimburse dapat diklik
            return FloatingActionButton(
              onPressed: onPressedAction,
              backgroundColor: buttonDisabled
                  ? Colors.grey
                  : const Color(0xFF6366F1),
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReimburseTile(BuildContext context, ReimburseModel item) {
    final dateStr = item.date != null
        ? DateFormat('dd MMM yyyy').format(item.date!)
        : '-';
    Color statusColor;
    switch (item.status) {
      case 'POSTED':
        statusColor = Colors.blue;
        break;
      case 'LUNAS':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (item.id != null) {
          if (item.status == "DRAFT") {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => AddReimbursePage(
            //       reimburseId: item.id!,
            //       isEdit: true,
            //     ),
            //   ),
            // );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailReimbursePage(reimburseId: item.id!),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reimburse ID is not available.')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  item.totalKm != null ? '${item.totalKm} KM' : '-',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.status ?? '-',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
