import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

/// ادا شدہ/باقی حالت دکھانے والا چھوٹا بیج
class StatusBadge extends StatelessWidget {
  final bool isPaid;

  const StatusBadge({super.key, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.paid : AppColors.pending;
    final text = isPaid ? AppStrings.statusPaid : AppStrings.statusPending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
