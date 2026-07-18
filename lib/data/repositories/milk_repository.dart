import '../../core/constants/app_constants.dart';
import '../database/db_helper.dart';
import '../models/milk_record_model.dart';
import '../models/milk_payment_model.dart';

/// دودھ کے ریکارڈز اور ادائیگیوں کی Repository
class MilkRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  // ---------- Milk Records ----------

  Future<int> insertRecord(MilkRecordModel record) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableMilkRecords, record.toMap());
  }

  Future<int> updateRecord(MilkRecordModel record) async {
    final db = await _dbHelper.database;
    return db.update(
      AppConstants.tableMilkRecords,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableMilkRecords, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MilkRecordModel>> getRecordsByCustomer(int customerId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMilkRecords,
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => MilkRecordModel.fromMap(m)).toList();
  }

  Future<List<MilkRecordModel>> getRecordsByMonth(String monthKey, {int? customerId}) async {
    final db = await _dbHelper.database;
    String where = "date LIKE ?";
    List<dynamic> args = ['$monthKey%'];
    if (customerId != null) {
      where += ' AND customer_id = ?';
      args.add(customerId);
    }
    final maps = await db.query(
      AppConstants.tableMilkRecords,
      where: where,
      whereArgs: args,
      orderBy: 'date DESC',
    );
    return maps.map((m) => MilkRecordModel.fromMap(m)).toList();
  }

  Future<List<MilkRecordModel>> getRecordsByDate(String isoDate) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMilkRecords,
      where: 'date = ?',
      whereArgs: [isoDate],
    );
    return maps.map((m) => MilkRecordModel.fromMap(m)).toList();
  }

  Future<double> getMonthlyTotalAmount(String monthKey) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(quantity_liters * price_per_liter) as total FROM ${AppConstants.tableMilkRecords} WHERE date LIKE ?",
      ['$monthKey%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ---------- Milk Payments ----------

  Future<int> insertPayment(MilkPaymentModel payment) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableMilkPayments, payment.toMap());
  }

  Future<int> deletePayment(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableMilkPayments, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MilkPaymentModel>> getPaymentsByCustomer(int customerId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableMilkPayments,
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => MilkPaymentModel.fromMap(m)).toList();
  }

  Future<double> getTotalPaidByCustomer(int customerId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ${AppConstants.tableMilkPayments} WHERE customer_id = ?",
      [customerId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalBillByCustomer(int customerId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(quantity_liters * price_per_liter) as total FROM ${AppConstants.tableMilkRecords} WHERE customer_id = ?",
      [customerId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// گاہک کا باقی رقم = کل بل - کل ادائیگی
  Future<double> getRemainingBalance(int customerId) async {
    final bill = await getTotalBillByCustomer(customerId);
    final paid = await getTotalPaidByCustomer(customerId);
    return bill - paid;
  }

  Future<double> getCurrentMonthTotalBill() async {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return getMonthlyTotalAmount(monthKey);
  }
}
