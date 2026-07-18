import '../../core/constants/app_constants.dart';
import '../database/db_helper.dart';
import '../models/rent_model.dart';

class RentRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(RentModel rent) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableRent, rent.toMap());
  }

  Future<int> update(RentModel rent) async {
    final db = await _dbHelper.database;
    return db.update(AppConstants.tableRent, rent.toMap(), where: 'id = ?', whereArgs: [rent.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableRent, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RentModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableRent, orderBy: 'month_key DESC');
    return maps.map((m) => RentModel.fromMap(m)).toList();
  }

  Future<RentModel?> getByMonthKey(String monthKey) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableRent,
      where: 'month_key = ?',
      whereArgs: [monthKey],
    );
    if (maps.isEmpty) return null;
    return RentModel.fromMap(maps.first);
  }

  Future<RentModel?> getLatest() async {
    final all = await getAll();
    if (all.isEmpty) return null;
    return all.first;
  }

  // ---------- Payments ----------

  Future<int> insertPayment(RentPaymentModel payment) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableRentPayments, payment.toMap());
  }

  Future<List<RentPaymentModel>> getPayments(int rentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableRentPayments,
      where: 'rent_id = ?',
      whereArgs: [rentId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => RentPaymentModel.fromMap(m)).toList();
  }
}
