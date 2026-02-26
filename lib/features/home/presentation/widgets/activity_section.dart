import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/home/presentation/providers/activity_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_card_decoration.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActivityProvider(),
      child: const _ActivitySectionContent(),
    );
  }
}

class _ActivitySectionContent extends StatefulWidget {
  const _ActivitySectionContent();

  @override
  State<_ActivitySectionContent> createState() =>
      _ActivitySectionContentState();
}

class _ActivitySectionContentState extends State<_ActivitySectionContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null && auth.salesId != null) {
        Provider.of<ActivityProvider>(
          context,
          listen: false,
        ).fetchActivity(auth.token!, auth.salesId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.activity == null) {
          return const SizedBox.shrink();
        }

        final activity = provider.activity!;
        final realization = activity.tVisitRealization;
        final startAt = realization?.startAt != null
            ? _formatTime(realization!.startAt!)
            : '-';
        final endAt = realization?.endAt != null
            ? _formatTime(realization!.endAt!)
            : '-';
        final isCheckedOut = realization?.endAt != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aktivitas Berlangsung",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: homeCardDecoration(color: const Color(0xFF6675F7)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.customerName ?? "Unknown Customer",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _checkCard("Check In", startAt, true),
                      const SizedBox(width: 12),
                      _checkCard("Check Out", endAt, isCheckedOut),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(String time) {
    try {
      // Assuming time comes as HH:mm:ss
      final parts = time.split(':');
      if (parts.length >= 2) {
        return "${parts[0]}:${parts[1]}";
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  Widget _checkCard(String title, String time, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.login : Icons.logout,
              color: active ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  time,
                  style: TextStyle(
                    color: active ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
