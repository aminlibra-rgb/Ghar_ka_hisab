import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

/// حذف کرنے یا کسی اہم عمل سے پہلے تصدیقی ڈائیلاگ
Future<bool> showConfirmDialog(
  BuildContext context, {
  String title = AppStrings.deleteConfirmTitle,
  String body = AppStrings.deleteConfirmBody,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.right),
      content: Text(body, textAlign: TextAlign.right),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(context, true),
          child: const Text(AppStrings.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}
