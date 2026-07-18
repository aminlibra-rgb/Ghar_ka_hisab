import '../../core/constants/app_constants.dart';
import '../database/db_helper.dart';
import '../models/bill_model.dart';

class BillRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(BillModel bill) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableBills, bill.toMap());
  }

  Future<int> update(BillModel bill) async {
    final db = await _dbHelper.database;
    return db.update(AppConstants.tableBills, bill.toMap(), where: 'id = ?', whereArgs: [bill.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableBills, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BillModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableBills, orderBy: 'due_date ASC');
    return maps.map((m) => BillModel.fromMap(m)).toList();
  }

  Future<List<BillModel>> getPending() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableBills,
      where: 'status = ?',
      whereArgs: [AppConstants.statusPending],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => BillModel.fromMap(m)).toList();
  }

  Future<double> getTotalPendingAmount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(total_amount - paid_amount) as total FROM ${AppConstants.tableBills} WHERE status = ?",
      [AppConstants.statusPending],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<BillModel>> getByMonth(String monthKey) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableBills,
      where: 'due_date LIKE ?',
      whereArgs: ['$monthKey%'],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => BillModel.fromMap(m)).toList();
  }

  Future<List<BillModel>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableBills,
      where: 'bill_name LIKE ? OR bill_type LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => BillModel.fromMap(m)).toList();
  }

  /// آنے والے دنوں میں واجب الادا بل (اطلاع کے لیے)
  Future<List<BillModel>> getUpcoming({int withinDays = 3}) async {
    final all = await getPending();
    final now = DateTime.now();
    return all.where((b) {
      final diff = b.dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
      return diff >= 0 && diff <= withinDays;
    }).toList();
  }
}
