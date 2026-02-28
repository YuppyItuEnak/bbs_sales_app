import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/sales_invoice/sales_target_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/target/presentation/providers/target_sales_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesTargetPage extends StatefulWidget {
  const SalesTargetPage({super.key});

  @override
  State<SalesTargetPage> createState() => _SalesTargetPageState();
}

class _SalesTargetPageState extends State<SalesTargetPage> {
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

    if (storedToken == null || authUserId == null) return;

    if (!mounted) return;

    final provider = context.read<TargetSalesProvider>();
    provider.fetchSalesTargetComparison(
      token: storedToken,
      salesId: authUserId,
      year: provider.selectedYear,
    );
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
            'Sales Target',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Consumer2<TargetSalesProvider, AuthProvider>(
          builder: (context, provider, authProvider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            final data = provider.salesTargetData;
            if (data == null) {
              return const Center(child: Text('No data available'));
            }

            final token = authProvider.token ?? '';
            final salesId = authProvider.user?.id ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildYearSelector(
                    provider: provider,
                    token: token,
                    salesId: salesId,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(data),
                  const SizedBox(height: 24),
                  const Text(
                    "Target Bulanan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...data.months.map((month) => _monthCard(month)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(SalesTargetDataModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         
          _progressCircle(data.summary.percentage / 100),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, 
              mainAxisSize: MainAxisSize.min,
              children: [
                _summaryItem(
                  "Terpenuhi",
                  _formatCurrency(data.summary.realisasi),
                ),
                const SizedBox(height: 16),

                _smallSummary("Target", _formatCurrency(data.summary.target)),
                const SizedBox(height: 8),
                _smallSummary(
                  "Sisa Target",
                  _formatCurrency(data.summary.sisa),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }


  Widget _smallSummary(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _progressCircle(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 90,
          width: 90,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: const Color(0xFFE0E4F2),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4C4CFF)),
          ),
        ),
        Text(
          "${(progress * 100).toStringAsFixed(1)}%",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _monthCard(SalesTargetMonthModel month) {
    Color color;
    if (month.percentage >= 100) {
      color = Colors.green;
    } else if (month.percentage >= 75) {
      color = Colors.blue;
    } else if (month.percentage >= 50) {
      color = Colors.amber;
    } else if (month.percentage > 0) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            month.month,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: month.percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${month.percentage.toStringAsFixed(1)}% (${_formatCurrency(month.realisasi)})",
                style: const TextStyle(color: Colors.black54),
              ),
              Text(
                _formatCurrency(month.target),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector({
    required TargetSalesProvider provider,
    required String token,
    required String salesId,
  }) {
    return Row(
      children: [
        const Text(
          'Periode',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        DropdownButton<int>(
          value: provider.selectedYear,
          underline: const SizedBox(),
          items: provider.yearOptions.map((year) {
            return DropdownMenuItem<int>(
              value: year,
              child: Text(
                year.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: (year) {
            if (year == null) return;
            provider.setYear(year, token: token, salesId: salesId);
          },
        ),
      ],
    );
  }

  String _formatCurrency(int value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
