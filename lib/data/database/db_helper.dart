import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';

/// ڈیٹا بیس ہیلپر - Singleton pattern کے ساتھ
/// یہ کلاس تمام ٹیبلز بناتی ہے اور ڈیٹا بیس کنکشن فراہم کرتی ہے۔
class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get dbPath async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, AppConstants.dbName);
  }

  Future<Database> _initDatabase() async {
    final path = await dbPath;
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // گاہک (دودھ)
    batch.execute('''
      CREATE TABLE ${AppConstants.tableCustomers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // دودھ کا یومیہ ریکارڈ
    batch.execute('''
      CREATE TABLE ${AppConstants.tableMilkRecords} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        quantity_liters REAL NOT NULL,
        price_per_liter REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (customer_id) REFERENCES ${AppConstants.tableCustomers} (id) ON DELETE CASCADE
      )
    ''');

    // دودھ کی ادائیگیاں
    batch.execute('''
      CREATE TABLE ${AppConstants.tableMilkPayments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (customer_id) REFERENCES ${AppConstants.tableCustomers} (id) ON DELETE CASCADE
      )
    ''');

    // آمدنی
    batch.execute('''
      CREATE TABLE ${AppConstants.tableIncome} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // اخراجات
    batch.execute('''
      CREATE TABLE ${AppConstants.tableExpense} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // بل
    batch.execute('''
      CREATE TABLE ${AppConstants.tableBills} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_name TEXT NOT NULL,
        bill_type TEXT NOT NULL,
        total_amount REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        due_date TEXT NOT NULL,
        payment_date TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        notes TEXT
      )
    ''');

    // ادھار لین دین
    batch.execute('''
      CREATE TABLE ${AppConstants.tableBorrowLend} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_name TEXT NOT NULL,
        phone_number TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        type TEXT NOT NULL
      )
    ''');

    // ادھار کی جزوی ادائیگیاں
    batch.execute('''
      CREATE TABLE ${AppConstants.tableBorrowLendPayments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        borrow_lend_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (borrow_lend_id) REFERENCES ${AppConstants.tableBorrowLend} (id) ON DELETE CASCADE
      )
    ''');

    // دکان کرایہ
    batch.execute('''
      CREATE TABLE ${AppConstants.tableRent} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_key TEXT NOT NULL UNIQUE,
        monthly_rent REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        due_date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // کرایہ کی جزوی ادائیگیاں
    batch.execute('''
      CREATE TABLE ${AppConstants.tableRentPayments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rent_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (rent_id) REFERENCES ${AppConstants.tableRent} (id) ON DELETE CASCADE
      )
    ''');

    // ایپ کی عمومی ترتیبات (اختیاری key-value اسٹور)
    batch.execute('''
      CREATE TABLE ${AppConstants.tableSettings} (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await batch.commit(noResult: true);
  }

  /// ڈیٹا بیس کنکشن بند کرنا (بیک اپ/ری اسٹور سے پہلے ضروری)
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }

  /// ری اسٹور کے بعد دوبارہ ڈیٹا بیس کھولنا
  Future<void> reopenDatabase() async {
    _database = await _initDatabase();
  }

  Future<File> getDatabaseFile() async {
    final path = await dbPath;
    return File(path);
  }
}
