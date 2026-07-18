import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';

/// جب کسی فہرست میں کوئی ڈیٹا نہ ہو تو دکھایا جانے والا خالی صفحہ
class EmptyState extends StatelessWidget {
  final String? message;
  final IconData icon;

  const EmptyState({super.key, this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message ?? AppStrings.noData,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
