import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

/// ایپ کھلتے وقت PIN یا فنگر پرنٹ کے ذریعے تصدیق کی اسکرین
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = '';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    final auth = context.read<AuthProvider>();
    if (auth.fingerprintEnabled) {
      await auth.tryUnlockWithBiometrics();
    }
  }

  void _onKeyTap(String digit) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _errorText = null;
    });
    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
  }

  Future<void> _verifyPin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.tryUnlockWithPin(_enteredPin);
    if (!ok) {
      setState(() {
        _errorText = 'غلط پن، دوبارہ کوشش کریں';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.home_work_rounded, color: Colors.white, size: 60),
              const SizedBox(height: 12),
              const Text(
                AppStrings.appName,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text('اپنا 4 ہندسی پن درج کریں', style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  );
                }),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Text(_errorText!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 40),
              Expanded(child: _buildKeypad()),
              if (auth.fingerprintEnabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    onPressed: () => auth.tryUnlockWithBiometrics(),
                    icon: const Icon(Icons.fingerprint, color: Colors.white, size: 42),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(6),
          child: Material(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => key == '⌫' ? _onBackspace() : _onKeyTap(key),
              child: Center(
                child: key == '⌫'
                    ? const Icon(Icons.backspace_outlined, color: Colors.white)
                    : Text(key, style: const TextStyle(color: Colors.white, fontSize: 22)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
