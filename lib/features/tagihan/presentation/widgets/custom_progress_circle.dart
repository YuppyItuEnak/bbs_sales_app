import 'package:flutter/material.dart';

class CustomProgressCircle extends StatelessWidget {
  final double percentage;
  final double size;

  const CustomProgressCircle({
    super.key,
    required this.percentage,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
            ),
          ),
          Text(
            "${(percentage * 100).toStringAsFixed(1)}%",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
