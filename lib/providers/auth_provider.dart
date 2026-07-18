import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';

/// ایپ لاک/ان لاک کی حالت کا انتظام
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SettingsService _settingsService = SettingsService();

  bool _isUnlocked = false;
  bool _pinEnabled = false;
  bool _fingerprintEnabled = false;

  bool get isUnlocked => _isUnlocked;
  bool get pinEnabled => _pinEnabled;
  bool get fingerprintEnabled => _fingerprintEnabled;

  AuthProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _pinEnabled = await _settingsService.getPinEnabled();
    _fingerprintEnabled = await _settingsService.getFingerprintEnabled();
    _isUnlocked = !_pinEnabled; // اگر پن لاک آن نہیں تو ایپ خودکار طور پر کھلی ہے
    notifyListeners();
  }

  Future<void> refreshSettings() => _loadSettings();

  Future<bool> tryUnlockWithPin(String pin) async {
    final ok = await _authService.verifyPin(pin);
    if (ok) {
      _isUnlocked = true;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> tryUnlockWithBiometrics() async {
    final ok = await _authService.authenticateWithBiometrics();
    if (ok) {
      _isUnlocked = true;
      notifyListeners();
    }
    return ok;
  }

  Future<void> setPinEnabled(bool value, {String? newPin}) async {
    _pinEnabled = value;
    await _settingsService.setPinEnabled(value);
    if (value && newPin != null) {
      await _settingsService.setPin(newPin);
    }
    if (!value) {
      await _settingsService.clearPin();
    }
    notifyListeners();
  }

  Future<void> setFingerprintEnabled(bool value) async {
    _fingerprintEnabled = value;
    await _settingsService.setFingerprintEnabled(value);
    notifyListeners();
  }

  void lockApp() {
    if (_pinEnabled) {
      _isUnlocked = false;
      notifyListeners();
    }
  }
}
