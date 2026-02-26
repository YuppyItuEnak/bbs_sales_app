import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/customer/customer_model.dart';
import 'package:bbs_sales_app/data/models/prospect/prospect_detail_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/create_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/pages/detail_customer_page.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_list_provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';
import 'package:bbs_sales_app/features/prospect/presentation/pages/detail_prospect_page.dart';
import 'package:bbs_sales_app/features/prospect/presentation/providers/prospect_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/pages/prospect_visit_form_page.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListCustomerPage extends StatefulWidget {
  const ListCustomerPage({super.key});

  @override
  State<ListCustomerPage> createState() => _ListCustomerPageState();
}

class _ListCustomerPageState extends State<ListCustomerPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final salesId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user?.id;
      if (token != null) {
        Provider.of<CustomerListProvider>(
          context,
          listen: false,
        ).fetchCustomersList();
        Provider.of<ProspectProvider>(
          context,
          listen: false,
        ).fetchListProspectName(token);
        if (salesId != null) {
          Provider.of<VisitProvider>(
            context,
            listen: false,
          ).checkOpenVisitWithoutCustomer(salesId, token);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            centerTitle: true,
            leading: const BackButton(color: Colors.black),
            title: const Text(
              'List Data',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            bottom: const TabBar(
              labelColor: Color(0xFF5F6BF7),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF5F6BF7),
              tabs: [
                Tab(text: 'Customer'),
                Tab(text: 'Prospek'),
              ],
            ),
          ),
          floatingActionButton: Consumer<VisitProvider>(
            builder: (context, visitProvider, child) {
              return FloatingActionButton(
                backgroundColor: visitProvider.hasOpenVisitWithoutCustomer
                    ? Colors.grey
                    : const Color(0xFF5F6BF7),
                shape: const CircleBorder(),
                elevation: 6,
                onPressed: visitProvider.hasOpenVisitWithoutCustomer
                    ? null
                    : () {
                        context.read<CustomerFormProvider>().clear();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProspectVisitFormPage(),
                          ),
                        );
                      },
                child: const Icon(Icons.add, color: Colors.white),
              );
            },
          ),
          body: Column(
            children: [
              _buildSearch(),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Customer List
                    Consumer<CustomerListProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (provider.errorMessage != null) {
                          return Center(
                            child: Text("Error: ${provider.errorMessage}"),
                          );
                        }
                        final filtered = provider.customers
                            .where(
                              (c) => (c.name ?? '').toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                        if (filtered.isEmpty) {
                          return const Center(
                            child: Text("No customers found."),
                          );
                        }
                        return _buildListView(filtered, _handleCustomerTap);
                      },
                    ),
                    // Tab 2: Prospect List
                    Consumer<ProspectProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoadingProspects) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final filtered = provider.prospects
                            .where(
                              (p) => (p.name ?? '').toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                        if (filtered.isEmpty) {
                          return const Center(
                            child: Text("No prospects found."),
                          );
                        }
                        return _buildListView(filtered, _handleProspectTap);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(
    List<CustomerModel> items,
    Function(CustomerModel) onTap,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _customerCard(item, onTap),
        );
      },
    );
  }

  // ===================== HANDLE TAP ======================
  void _handleProspectTap(CustomerModel customer) {
    // Mapping CustomerModel to ProspectDetailModel
    // Note: In a real scenario, you might want to fetch full details from API here
    final prospectDetail = ProspectDetailModel(
      name: customer.name,
      phone: customer.phone,
      contactPerson: customer.contactPerson,
      // Map other fields if available in CustomerModel or leave as null
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProspectPage(prospect: prospectDetail),
      ),
    );
  }

  void _handleCustomerTap(CustomerModel customer) {
    final status = customer.status ?? 0;

    // Status 2 (In Approval) & 9 (Rejected) -> View Only
    if (status == 2 || status == 9) {
      context.read<CustomerFormProvider>().loadCustomerForEdit(customer);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerDetailPage(isViewOnly: true),
        ),
      );
      return;
    }

    // Status 1 (Draft), 3 (Revision), 4 (Approved) -> Show Options
    if (status == 1 || status == 3 || status == 4) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Lihat'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<CustomerFormProvider>().loadCustomerForEdit(
                      customer,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CustomerDetailPage(isViewOnly: true),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<CustomerFormProvider>().loadCustomerForEdit(
                      customer,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateCustomerPage(customer: customer),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // ===================== SEARCH ======================
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari",
                  border: InputBorder.none,
                ),
              ),
            ),
            Icon(Icons.tune, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ===================== CARD ======================
  Widget _customerCard(CustomerModel c, Function(CustomerModel) onTap) {
    // The selection logic is removed as per new flow
    // final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onTap(c),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Border is removed as selection is no longer needed
          // border: Border.all(
          //   color: isSelected ? const Color(0xFF2979FF) : Colors.transparent,
          //   width: 2,
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (c.status == 4) // Approved
                  const Icon(Icons.verified, size: 18, color: Colors.green),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "No address available", // Address is not in CustomerModel
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              "${c.contactPerson} | ${c.phone ?? '-'}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 14),
            _statusChip(c.status ?? 0),
          ],
        ),
      ),
    );
  }

  // ===================== STATUS ======================
  Map<String, dynamic> _getStatusInfo(int status) {
    switch (status) {
      case 1: // Draft
        return {
          'text': 'Draft',
          'color': Colors.blueGrey,
          'bg': Colors.blueGrey.shade100,
        };
      case 2: // In Approval
        return {
          'text': 'In Approval',
          'color': Colors.orange,
          'bg': Colors.orange.shade100,
        };
      case 3: // Revision
        return {
          'text': 'Revision',
          'color': Colors.purple,
          'bg': Colors.purple.shade100,
        };
      case 4: // Approved
        return {
          'text': 'Approved',
          'color': Colors.green,
          'bg': Colors.green.shade100,
        };
      case 9: // Rejected
        return {
          'text': 'Rejected',
          'color': Colors.red,
          'bg': Colors.red.shade100,
        };
      default:
        return {
          'text': 'Unknown',
          'color': Colors.grey,
          'bg': Colors.grey.shade200,
        };
    }
  }

  Widget _statusChip(int status) {
    final statusInfo = _getStatusInfo(status);
    final color = statusInfo['color'] as Color;
    final bg = statusInfo['bg'] as Color;
    final text = statusInfo['text'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
