import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// شیئرڈ پریفرنسز کے ذریعے ایپ کی ترتیبات محفوظ کرنے کی سروس
class SettingsService {
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDarkMode, value);
  }

  Future<double> getMilkPrice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(AppConstants.prefMilkPrice) ?? 200.0;
  }

  Future<void> setMilkPrice(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefMilkPrice, value);
  }

  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefPin);
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefPin, pin);
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefPin);
    await prefs.setBool(AppConstants.prefPinEnabled, false);
  }

  Future<bool> getPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefPinEnabled) ?? false;
  }

  Future<void> setPinEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefPinEnabled, value);
  }

  Future<bool> getFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefFingerprintEnabled) ?? false;
  }

  Future<void> setFingerprintEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefFingerprintEnabled, value);
  }

  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefFirstRun) ?? true;
  }

  Future<void> setFirstRunDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefFirstRun, false);
  }
}
