import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../data/database/db_helper.dart';
import '../core/utils/date_formatter.dart';

/// ڈیٹا بیس کا بیک اپ لینے اور بحال کرنے کی سروس
class BackupService {
  final DBHelper _dbHelper = DBHelper.instance;

  /// موجودہ ڈیٹا بیس فائل کو ڈیوائس کے "Downloads" یا منتخب کردہ فولڈر میں کاپی کرنا
  Future<String?> backupDatabase() async {
    try {
      final dbFile = await _dbHelper.getDatabaseFile();
      if (!await dbFile.exists()) return null;

      // بیک اپ فائل کا نام تاریخ کے ساتھ
      final fileName = 'ghar_ka_hisab_backup_${DateFormatter.toDbFormat(DateTime.now())}.db';

      final selectedDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'بیک اپ محفوظ کرنے کے لیے مقام منتخب کریں',
      );

      if (selectedDir == null) {
        // اگر صارف نے کوئی مقام منتخب نہیں کیا تو ایپ کے دستاویزات فولڈر میں محفوظ کریں
        final docsDir = await getApplicationDocumentsDirectory();
        final backupPath = '${docsDir.path}/$fileName';
        await dbFile.copy(backupPath);
        return backupPath;
      }

      final backupPath = '$selectedDir/$fileName';
      await dbFile.copy(backupPath);
      return backupPath;
    } catch (e) {
      return null;
    }
  }

  /// صارف کی منتخب کردہ .db فائل سے ڈیٹا بحال کرنا
  Future<bool> restoreDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'بیک اپ فائل منتخب کریں',
        type: FileType.any,
      );
      if (result == null || result.files.single.path == null) return false;

      final pickedFile = File(result.files.single.path!);
      final dbFile = await _dbHelper.getDatabaseFile();

      // بحالی سے پہلے موجودہ کنکشن بند کرنا ضروری ہے
      await _dbHelper.closeDatabase();

      await pickedFile.copy(dbFile.path);

      await _dbHelper.reopenDatabase();
      return true;
    } catch (e) {
      await _dbHelper.reopenDatabase();
      return false;
    }
  }
}
