import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/tagihan/customer_billing_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/tagihan/presentation/pages/list_invoice_page.dart';
import 'package:bbs_sales_app/features/tagihan/presentation/providers/detail_tagihan_provider.dart';
import 'package:bbs_sales_app/features/tagihan/presentation/widgets/custom_progress_circle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailTagihanPage extends StatefulWidget {
  final CustomerBilling customerBilling;
  const DetailTagihanPage({super.key, required this.customerBilling});

  @override
  State<DetailTagihanPage> createState() => _DetailTagihanPageState();
}

class _DetailTagihanPageState extends State<DetailTagihanPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DetailTagihanProvider>(
        context,
        listen: false,
      );
      provider.fetchDetailTagihan(
        customerId: widget.customerBilling.customerId,
        startDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        endDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '', // Menghilangkan simbol agar bisa diatur manual di teks
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Detail Tagihan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: Consumer<DetailTagihanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = provider.summary;
          if (summary == null)
            return const Center(child: Text("Data tidak ditemukan"));

          final percentage = summary.totalPiutang > 0
              ? (summary.sisaPiutang / summary.totalPiutang)
              : 0.0;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.customerBilling.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderInfo(
                          "Ina Halima",
                          widget.customerBilling.phone,
                        ),
                        _buildHeaderInfo(
                          "Tanggal Penagihan",
                          "06 Desember 2023",
                          crossAxis: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    ),
                    // Progress Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircularProgress(
                          75,
                        ), // Nilai statis sesuai SS atau (percentage * 100).toInt()
                        const SizedBox(width: 35),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sisa Piutang",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "25.000.000", // Ganti dengan currencyFormatter.format(summary.sisaPiutang)
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Piutang 100.000.000", // Ganti summary.totalPiutang
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    ),
                    const Text(
                      "Histori Penagihan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...provider.history
                        .map(
                          (item) => _buildHistoryItem(item, currencyFormatter),
                        )
                        .toList(),
                  ],
                ),
              ),
              // Button Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B67F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListInvoicePage(
                          billingScheduleId: widget
                              .customerBilling
                              .tInvoiceBillingScheduleCustId,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Tagih",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(
    String label,
    String value, {
    CrossAxisAlignment crossAxis = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(int value) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 8,
            backgroundColor: const Color(0xFFE8EAF6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B67F1)),
          ),
        ),
        Text(
          "$value%",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(dynamic item, NumberFormat formatter) {
    final bool isLunas = item.status == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "06 Des",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "2023",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: !isLunas
                      ? const Color(0xFF5B67F1)
                      : const Color(0xFFF5F5F5),
                  width: !isLunas ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rp 25.000.000",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLunas ? "Transfer Bank" : "-",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLunas
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isLunas
                            ? Colors.green.shade200
                            : const Color(0xFFFFD54F),
                      ),
                    ),
                    child: Text(
                      isLunas ? "Lunas" : "Belum Lunas",
                      style: TextStyle(
                        color: isLunas ? Colors.green : const Color(0xFFFFB300),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
