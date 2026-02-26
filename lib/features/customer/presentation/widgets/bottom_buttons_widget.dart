import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const BottomButtons({super.key, required this.onNext, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBack ?? onNext,
              child: const Text("Lewati"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text("Lanjut"),
            ),
          ),
        ],
      ),
    );
  }
}
