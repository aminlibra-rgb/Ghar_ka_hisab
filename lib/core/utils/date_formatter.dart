import 'package:intl/intl.dart';

/// تاریخ کو مختلف شکلوں میں ظاہر کرنے کے لیے مددگار کلاس
class DateFormatter {
  DateFormatter._();

  /// 12-Jul-2026 طرز پر تاریخ
  static String display(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  /// ڈیٹا بیس میں محفوظ کرنے کے لیے ISO فارمیٹ (yyyy-MM-dd)
  static String toDbFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime fromDbFormat(String value) {
    return DateFormat('yyyy-MM-dd').parse(value);
  }

  /// مہینہ اور سال، مثلاً "جولائی 2026"
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String monthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String dayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static int daysUntil(DateTime target) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(target.year, target.month, target.day);
    return targetDay.difference(today).inDays;
  }
}
