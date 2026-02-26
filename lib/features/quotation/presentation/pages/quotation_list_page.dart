import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/features/quotation/presentation/pages/quotation_form_page.dart';
import 'package:bbs_sales_app/features/quotation/presentation/widget/quotation_card.dart';
import 'package:bbs_sales_app/features/quotation/presentation/widget/quotation_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/quotation_provider.dart';

class QuotationListPage extends StatefulWidget {
  const QuotationListPage({super.key});

  @override
  State<QuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quotationProvider = Provider.of<QuotationProvider>(
      context,
      listen: false,
    );

    if (authProvider.user?.userDetails.isNotEmpty == true) {
      final salesId = authProvider.user!.userDetails.first.fUserDefault;
      await quotationProvider.fetchQuotations(
        salesId!,
        authProvider.token!,
        isRefresh: true,
      );
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
            'Quotation',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          child: FloatingActionButton(
            elevation: 6,
            shape: const CircleBorder(),
            backgroundColor: const Color(0xFF5F6BF7),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuotationFormPage()),
              );
              await _fetchData();
            },
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ),

        body: Consumer<QuotationProvider>(
          builder: (context, quotationProvider, child) {
            if (quotationProvider.isLoading &&
                quotationProvider.quotations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (quotationProvider.error != null &&
                quotationProvider.quotations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(quotationProvider.error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final quotations = quotationProvider.quotations;

            return RefreshIndicator(
              onRefresh: _fetchData,
              child: Column(
                children: [
                  QuotationSearchBar(
                    onSubmitted: (value) {
                      quotationProvider.setSearchKeyword(value);
                      _fetchData();
                    },
                  ),
                  Expanded(
                    child: quotations.isEmpty
                        ? const Center(child: Text('No quotations found'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: quotations.length,
                            itemBuilder: (context, index) {
                              final quotation = quotations[index];
                              return QuotationCard(
                                quotation: quotation,
                                onReturn: _fetchData,
                              );
                            },
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
