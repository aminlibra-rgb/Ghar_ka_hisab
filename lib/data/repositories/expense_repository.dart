import '../../core/constants/app_constants.dart';
import '../database/db_helper.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableExpense, expense.toMap());
  }

  Future<int> update(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return db.update(AppConstants.tableExpense, expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableExpense, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExpenseModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableExpense, orderBy: 'date DESC');
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<List<ExpenseModel>> getByMonth(String monthKey) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableExpense,
      where: 'date LIKE ?',
      whereArgs: ['$monthKey%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<List<ExpenseModel>> getByDateRange(String startIso, String endIso) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableExpense,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startIso, endIso],
      orderBy: 'date DESC',
    );
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<double> getMonthlyTotal(String monthKey) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ${AppConstants.tableExpense} WHERE date LIKE ?",
      ['$monthKey%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery("SELECT SUM(amount) as total FROM ${AppConstants.tableExpense}");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<ExpenseModel>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableExpense,
      where: 'notes LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<Map<String, double>> getCategoryTotalsForMonth(String monthKey) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT category, SUM(amount) as total FROM ${AppConstants.tableExpense} WHERE date LIKE ? GROUP BY category",
      ['$monthKey%'],
    );
    final map = <String, double>{};
    for (final row in result) {
      map[row['category'] as String] = (row['total'] as num?)?.toDouble() ?? 0.0;
    }
    return map;
  }
}
