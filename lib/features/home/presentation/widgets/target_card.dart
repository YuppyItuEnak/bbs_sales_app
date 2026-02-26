import 'package:bbs_sales_app/core/utils/format_util.dart';
import 'package:bbs_sales_app/features/target/presentation/providers/target_sales_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TargetCard extends StatelessWidget {
  const TargetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TargetSalesProvider>(
      builder: (context, provider, child) {
        final data = provider.salesTargetData;
        final today = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5F6BF7), Color(0xFF63C7F5)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(today, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text("Rank 02", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _targetItem(
                    "Target",
                    data != null
                        ? FormatUtil.currency(data.summary.target)
                        : "0",
                  ),
                  const VerticalDivider(color: Colors.white30),
                  _targetItem(
                    "Total Pencapaian",
                    data != null
                        ? FormatUtil.currency(data.summary.realisasi)
                        : "0",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _targetItem(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
