import '../../core/constants/app_constants.dart';
import '../database/db_helper.dart';
import '../models/borrow_lend_model.dart';

class BorrowLendRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(BorrowLendModel item) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableBorrowLend, item.toMap());
  }

  Future<int> update(BorrowLendModel item) async {
    final db = await _dbHelper.database;
    return db.update(AppConstants.tableBorrowLend, item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableBorrowLend, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BorrowLendModel>> getByType(String type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableBorrowLend,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return maps.map((m) => BorrowLendModel.fromMap(m)).toList();
  }

  Future<List<BorrowLendModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableBorrowLend, orderBy: 'date DESC');
    return maps.map((m) => BorrowLendModel.fromMap(m)).toList();
  }

  Future<List<BorrowLendModel>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableBorrowLend,
      where: 'person_name LIKE ? OR phone_number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => BorrowLendModel.fromMap(m)).toList();
  }

  // ---------- Payments ----------

  Future<int> insertPayment(BorrowLendPaymentModel payment) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableBorrowLendPayments, payment.toMap());
  }

  Future<int> deletePayment(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableBorrowLendPayments, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BorrowLendPaymentModel>> getPayments(int borrowLendId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableBorrowLendPayments,
      where: 'borrow_lend_id = ?',
      whereArgs: [borrowLendId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => BorrowLendPaymentModel.fromMap(m)).toList();
  }

  Future<double> getTotalPaid(int borrowLendId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ${AppConstants.tableBorrowLendPayments} WHERE borrow_lend_id = ?",
      [borrowLendId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// کسی مخصوص قسم (given/received) کی کل باقی رقم
  Future<double> getTotalRemainingByType(String type) async {
    final items = await getByType(type);
    double totalRemaining = 0;
    for (final item in items) {
      final paid = await getTotalPaid(item.id!);
      final remaining = item.amount - paid;
      if (remaining > 0) totalRemaining += remaining;
    }
    return totalRemaining;
  }
}
