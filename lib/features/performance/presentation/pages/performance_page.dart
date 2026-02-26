import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/performance/presentation/providers/performance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final authUserId = authProvider.user?.id ?? '';

    if (storedToken == null || authUserId.isEmpty) return;

    if (!mounted) return;

    context.read<PerformanceProvider>().fetchPerformanceData(
      token: storedToken,
      salesId: authUserId,
    );
  }

  String _formatCurrency(int value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const BackButton(color: Colors.black),
          title: const Text(
            "Performance",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<PerformanceProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingSalesTarget ||
                provider.isLoadingVisitTarget ||
                provider.isLoadingCustomerTarget) {
              return const Center(child: CircularProgressIndicator());
            }

            final salesData = provider.salesTargetData;
            final visitData = provider.visitTargetData;
            final customerData = provider.customerTargetData;

            // Get monthly data based on selected month
            final currentMonthSales = provider.getCurrentMonthSalesData();
            final currentMonthVisit = provider.getCurrentMonthVisitData();
            final currentMonthCustomer = provider.getCurrentMonthCustomerData();

            return RefreshIndicator(
              onRefresh: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final prefs = await SharedPreferences.getInstance();
                final storedToken = prefs.getString('auth_token');
                final authUserId = authProvider.user?.id ?? '';

                if (storedToken != null && authUserId.isNotEmpty) {
                  provider.fetchPerformanceData(
                    token: storedToken,
                    salesId: authUserId,
                  );
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Target Tahunan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        DropdownButton<int>(
                          value: provider.selectedYear,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: provider.yearOptions.map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (year) {
                            if (year == null) return;
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final authUserId = authProvider.user?.id ?? '';
                            provider.setYear(
                              year,
                              token: authProvider.token ?? '',
                              salesId: authUserId,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- Card Omset Besar ---
                    _buildMainTargetCard(salesData),

                    const SizedBox(height: 16),

                    // --- Grid untuk Visit & Customer Baru ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: "Visit",
                            target: visitData?.summary.target.toString() ?? "0",
                            completed:
                                visitData?.summary.realisasi.toString() ?? "0",
                            progress: visitData != null
                                ? visitData.summary.percentage / 100
                                : 0.0,
                            color: const Color(0xFFF87171), // Red/Coral
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            title: "Customer Baru",
                            target:
                                customerData?.summary.target.toString() ?? "0",
                            completed:
                                customerData?.summary.realisasi.toString() ??
                                "0",
                            progress: customerData != null
                                ? customerData.summary.percentage / 100
                                : 0.0,
                            color: const Color(0xFF4ADE80), // Green
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // --- Grid untuk Produk Terlaris & Customer Terloyal ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: "Produk Terlaris",
                            value: "Item 0001",
                            subtitle: "KODE-ITEM",
                            color: const Color(0xFF60A5FA), // Blue
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            title: "Customer Teroyal",
                            value: "Customer 0001",
                            subtitle: "CUST-0001",
                            color: const Color(0xFFFBBF24), // Yellow/Orange
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- Bagian Target Bulanan ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Target Bulanan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        DropdownButton<int>(
                          value: provider.selectedMonthIndex,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: provider.monthOptions.asMap().entries.map((
                            entry,
                          ) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (index) {
                            if (index == null) return;
                            provider.setMonth(index);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Monthly data based on selected month
                    _buildMonthlyProgressTile(
                      "Omset",
                      currentMonthSales != null
                          ? "${_formatCurrency(currentMonthSales.realisasi)} (${currentMonthSales.percentage.toStringAsFixed(1)}%)"
                          : "Rp 0 (0%)",
                      currentMonthSales != null
                          ? _formatCurrency(currentMonthSales.target)
                          : "Rp 0",
                      currentMonthSales != null
                          ? currentMonthSales.percentage / 100
                          : 0.0,
                      const Color(0xFF6366F1),
                    ),
                    _buildMonthlyProgressTile(
                      "Customer Baru",
                      currentMonthCustomer != null
                          ? "${currentMonthCustomer.realisasi} Customer (${currentMonthCustomer.percentage.toStringAsFixed(1)}%)"
                          : "0 Customer (0%)",
                      currentMonthCustomer != null
                          ? currentMonthCustomer.target.toString()
                          : "0",
                      currentMonthCustomer != null
                          ? currentMonthCustomer.percentage / 100
                          : 0.0,
                      const Color(0xFF4ADE80),
                    ),
                    _buildMonthlyProgressTile(
                      "Visit",
                      currentMonthVisit != null
                          ? "${currentMonthVisit.realisasi} Visit (${currentMonthVisit.percentage.toStringAsFixed(1)}%)"
                          : "0 Visit (0%)",
                      currentMonthVisit != null
                          ? currentMonthVisit.target.toString()
                          : "0",
                      currentMonthVisit != null
                          ? currentMonthVisit.percentage / 100
                          : 0.0,
                      const Color(0xFFFBBF24),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget Kartu Target Utama (Omset)
  Widget _buildMainTargetCard(salesData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Omset",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salesData != null
                        ? _formatCurrency(salesData.summary.target)
                        : "Rp 0",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Target",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salesData != null
                        ? _formatCurrency(salesData.summary.realisasi)
                        : "Rp 0",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Completed",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Progress",
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: salesData != null
                  ? salesData.summary.percentage / 100
                  : 0.0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Kartu Progress (Visit & Customer Baru)
  Widget _buildSummaryCard({
    required String title,
    required String target,
    required String completed,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallValueColumn(target, "Target"),
              _buildSmallValueColumn(completed, "Completed"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Progress",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Kartu Informasi (Produk/Customer Terlaris)
  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Helper untuk kolom angka kecil di kartu
  Widget _buildSmallValueColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  // Widget List Bulanan di bawah
  Widget _buildMonthlyProgressTile(
    String title,
    String current,
    String total,
    double progress,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                current,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              Text(
                total,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
