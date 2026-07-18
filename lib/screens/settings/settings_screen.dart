import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/backup_service.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _backupService = BackupService();
  final _authService = AuthService();
  bool _isProcessing = false;

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  Future<void> _handleBackup() async {
    setState(() => _isProcessing = true);
    final path = await _backupService.backupDatabase();
    setState(() => _isProcessing = false);
    _showToast(path != null ? 'بیک اپ کامیابی سے محفوظ ہو گیا' : 'بیک اپ ناکام ہو گیا');
  }

  Future<void> _handleRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ڈیٹا بحال کریں؟', textAlign: TextAlign.right),
        content: const Text('موجودہ ڈیٹا بیک اپ فائل سے بدل دیا جائے گا۔ یہ عمل واپس نہیں ہو سکتا۔', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    final success = await _backupService.restoreDatabase();
    setState(() => _isProcessing = false);
    _showToast(success ? 'ڈیٹا کامیابی سے بحال ہو گیا' : 'بحالی ناکام ہو گئی');
  }

  void _showSetPinDialog(AuthProvider auth) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.changePin, textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'نیا 4 ہندسی پن'),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'پن دوبارہ درج کریں'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length != 4 || pinController.text != confirmController.text) {
                _showToast('پن مماثل نہیں یا نامکمل ہے');
                return;
              }
              await auth.setPinEnabled(true, newPin: pinController.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _sectionTitle('ظاہری شکل'),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text(AppStrings.darkMode, textAlign: TextAlign.right),
                  value: themeProvider.isDarkMode,
                  onChanged: (v) => themeProvider.toggleTheme(v),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money_rounded),
                  title: const Text(AppStrings.currency, textAlign: TextAlign.right),
                  trailing: const Text('PKR (روپے)'),
                ),
                const Divider(),
                _sectionTitle('حفاظت'),
                SwitchListTile(
                  secondary: const Icon(Icons.lock_outline),
                  title: const Text(AppStrings.pinLock, textAlign: TextAlign.right),
                  value: authProvider.pinEnabled,
                  onChanged: (v) async {
                    if (v) {
                      _showSetPinDialog(authProvider);
                    } else {
                      await authProvider.setPinEnabled(false);
                    }
                  },
                ),
                if (authProvider.pinEnabled)
                  ListTile(
                    leading: const Icon(Icons.password_rounded),
                    title: const Text(AppStrings.changePin, textAlign: TextAlign.right),
                    onTap: () => _showSetPinDialog(authProvider),
                  ),
                FutureBuilder<bool>(
                  future: _authService.canCheckBiometrics(),
                  builder: (context, snapshot) {
                    if (snapshot.data != true) return const SizedBox.shrink();
                    return SwitchListTile(
                      secondary: const Icon(Icons.fingerprint_rounded),
                      title: const Text(AppStrings.fingerprintAuth, textAlign: TextAlign.right),
                      value: authProvider.fingerprintEnabled,
                      onChanged: authProvider.pinEnabled
                          ? (v) => authProvider.setFingerprintEnabled(v)
                          : null,
                    );
                  },
                ),
                const Divider(),
                _sectionTitle(AppStrings.backup),
                ListTile(
                  leading: const Icon(Icons.backup_outlined, color: AppColors.primary),
                  title: const Text(AppStrings.backupDatabase, textAlign: TextAlign.right),
                  onTap: _handleBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.restore_outlined, color: AppColors.danger),
                  title: const Text(AppStrings.restoreDatabase, textAlign: TextAlign.right),
                  onTap: _handleRestore,
                ),
                const Divider(),
                _sectionTitle(AppStrings.about),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(AppStrings.appName, textAlign: TextAlign.right),
                  subtitle: Text('ورژن 1.0.0 - مکمل آفلائن گھریلو اکاؤنٹنگ ایپ', textAlign: TextAlign.right),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
