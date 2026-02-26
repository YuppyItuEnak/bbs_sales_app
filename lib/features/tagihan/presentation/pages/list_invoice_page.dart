import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/tagihan/invoice_detail_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/tagihan/presentation/pages/bayar_tagihan_page.dart';
import 'package:bbs_sales_app/features/tagihan/presentation/providers/list_invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListInvoicePage extends StatelessWidget {
  final String billingScheduleId;

  const ListInvoicePage({super.key, required this.billingScheduleId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ListInvoiceProvider(
        Provider.of<AuthProvider>(context, listen: false),
      ),
      child: ListInvoiceView(billingScheduleId: billingScheduleId),
    );
  }
}

class ListInvoiceView extends StatefulWidget {
  final String billingScheduleId;
  const ListInvoiceView({super.key, required this.billingScheduleId});

  @override
  State<ListInvoiceView> createState() => _ListInvoiceViewState();
}

class _ListInvoiceViewState extends State<ListInvoiceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListInvoiceProvider>().fetchInvoiceDetail(
        widget.billingScheduleId,
      );
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
            'List Invoice Tagihan',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: Consumer<ListInvoiceProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text("Error: ${provider.error}"));
            }

            if (provider.invoiceDetail == null) {
              return const Center(child: Text("No data available."));
            }

            final customer = provider.invoiceDetail!.mCustomer;
            final invoices =
                provider.invoiceDetail!.tInvoiceBillingScheduleCustDs;
            final billingDate = provider.invoiceDetail!.billingDate;

            return Column(
              children: [
                // --- HEADER INFO SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.contactPerson,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                customer.phone,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Tanggal Penagihan",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMMM yyyy').format(billingDate),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- LIST ITEMS ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final item = invoices[index];
                      final isSelected = provider.selectedInvoiceIds.contains(
                        item.id,
                      );

                      return GestureDetector(
                        onTap: () => provider.toggleInvoiceSelection(item.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF5B67F1)
                                  : const Color(0xFFF1F1F1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: isSelected
                                    ? const Color(0xFF5B67F1)
                                    : Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.tSalesInvoice.code,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(item.tSalesInvoice.grandTotal),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF5B67F1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --- BOTTOM BUTTON ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B67F1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: provider.selectedInvoiceIds.isEmpty
                          ? null
                          : () {
                              final selectedInvoices = provider
                                  .invoiceDetail!
                                  .tInvoiceBillingScheduleCustDs
                                  .where(
                                    (invoice) => provider.selectedInvoiceIds
                                        .contains(invoice.id),
                                  )
                                  .toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BayarTagihanPage(
                                    selectedInvoices: selectedInvoices,
                                    totalAmount: provider.totalSelectedAmount,
                                    billingScheduleCustId:
                                        widget.billingScheduleId,
                                    allInvoices: provider
                                        .invoiceDetail!
                                        .tInvoiceBillingScheduleCustDs,
                                  ),
                                ),
                              );
                            },
                      child: Text(
                        "Bayar (${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(provider.totalSelectedAmount)})",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
