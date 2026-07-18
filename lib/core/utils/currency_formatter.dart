import 'package:intl/intl.dart';

/// رقم کو پاکستانی روپے کی شکل میں فارمیٹ کرنے کے لیے
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'Rs ',
    decimalDigits: 0,
  );

  static final NumberFormat _formatterDecimal = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'Rs ',
    decimalDigits: 2,
  );

  /// عام استعمال کے لیے - بغیر اعشاریہ
  static String format(num amount) {
    return _formatter.format(amount);
  }

  /// جہاں اعشاریہ ضروری ہو (مثلاً لیٹر کی قیمت)
  static String formatDecimal(num amount) {
    return _formatterDecimal.format(amount);
  }

  /// صرف عدد کو کوما کے ساتھ فارمیٹ کرنا، بغیر کرنسی نشان کے
  static String formatNumber(num amount) {
    return NumberFormat('#,##0', 'en_PK').format(amount);
  }
}
