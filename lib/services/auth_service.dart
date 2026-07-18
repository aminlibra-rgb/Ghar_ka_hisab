import 'package:local_auth/local_auth.dart';
import 'settings_service.dart';

/// PIN اور فنگر پرنٹ کی تصدیق کی سروس
class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SettingsService _settingsService = SettingsService();

  Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await _settingsService.getPin();
    return savedPin != null && savedPin == enteredPin;
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await canCheckBiometrics();
      final supported = await isDeviceSupported();
      if (!canCheck || !supported) return false;

      return await _localAuth.authenticate(
        localizedReason: 'براہ کرم اپنی شناخت کی تصدیق کریں',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLockEnabled() async {
    final pinEnabled = await _settingsService.getPinEnabled();
    return pinEnabled;
  }
}
