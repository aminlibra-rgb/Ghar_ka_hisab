import 'package:flutter/material.dart';

/// مرکزی رنگوں کا مجموعہ - پوری ایپ میں یہیں سے رنگ استعمال ہوں گے
/// تاکہ ایک جیسا اور خوبصورت تھیم برقرار رہے۔
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF2E7D32); // Green - گھریلو حساب کتاب
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF81C784);

  static const Color secondary = Color(0xFF1565C0); // Blue
  static const Color secondaryLight = Color(0xFF64B5F6);

  static const Color accent = Color(0xFFFF8F00); // Amber/Orange

  // Status colors
  static const Color income = Color(0xFF2E7D32);
  static const Color expense = Color(0xFFC62828);
  static const Color pending = Color(0xFFEF6C00);
  static const Color paid = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0277BD);

  // Neutral - Light theme
  static const Color backgroundLight = Color(0xFFF5F7F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1C1B1F);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);

  // Neutral - Dark theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFECECEC);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);

  // Card gradient sets used on dashboard
  static const List<Color> balanceGradient = [Color(0xFF2E7D32), Color(0xFF66BB6A)];
  static const List<Color> incomeGradient = [Color(0xFF1565C0), Color(0xFF42A5F5)];
  static const List<Color> expenseGradient = [Color(0xFFC62828), Color(0xFFEF5350)];
  static const List<Color> milkGradient = [Color(0xFF6A1B9A), Color(0xFFAB47BC)];
  static const List<Color> billsGradient = [Color(0xFFEF6C00), Color(0xFFFFA726)];
  static const List<Color> receivableGradient = [Color(0xFF00838F), Color(0xFF26C6DA)];
  static const List<Color> payableGradient = [Color(0xFFAD1457), Color(0xFFEC407A)];
  static const List<Color> rentGradient = [Color(0xFF37474F), Color(0xFF78909C)];
}
