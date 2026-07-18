import '../../core/constants/app_constants.dart';
import '../database/db_helper.dart';
import '../models/income_model.dart';

class IncomeRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(IncomeModel income) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableIncome, income.toMap());
  }

  Future<int> update(IncomeModel income) async {
    final db = await _dbHelper.database;
    return db.update(AppConstants.tableIncome, income.toMap(), where: 'id = ?', whereArgs: [income.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableIncome, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<IncomeModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableIncome, orderBy: 'date DESC');
    return maps.map((m) => IncomeModel.fromMap(m)).toList();
  }

  Future<List<IncomeModel>> getByMonth(String monthKey) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableIncome,
      where: 'date LIKE ?',
      whereArgs: ['$monthKey%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => IncomeModel.fromMap(m)).toList();
  }

  Future<List<IncomeModel>> getByDateRange(String startIso, String endIso) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableIncome,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startIso, endIso],
      orderBy: 'date DESC',
    );
    return maps.map((m) => IncomeModel.fromMap(m)).toList();
  }

  Future<double> getMonthlyTotal(String monthKey) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ${AppConstants.tableIncome} WHERE date LIKE ?",
      ['$monthKey%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery("SELECT SUM(amount) as total FROM ${AppConstants.tableIncome}");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<IncomeModel>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableIncome,
      where: 'title LIKE ? OR notes LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => IncomeModel.fromMap(m)).toList();
  }

  Future<Map<String, double>> getCategoryTotalsForMonth(String monthKey) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT category, SUM(amount) as total FROM ${AppConstants.tableIncome} WHERE date LIKE ? GROUP BY category",
      ['$monthKey%'],
    );
    final map = <String, double>{};
    for (final row in result) {
      map[row['category'] as String] = (row['total'] as num?)?.toDouble() ?? 0.0;
    }
    return map;
  }
}
