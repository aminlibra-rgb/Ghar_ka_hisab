import '../constants/app_strings.dart';

/// فارم ان پٹس کی تصدیق کے لیے مشترکہ فنکشنز
class Validators {
  Validators._();

  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterTitle;
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterValidAmount;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return AppStrings.pleaseEnterValidAmount;
    }
    return null;
  }

  static String? optionalAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return AppStrings.pleaseEnterValidAmount;
    }
    return null;
  }
}
