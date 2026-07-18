import '../../core/constants/app_constants.dart';
import '../database/db_helper.dart';
import '../models/customer_model.dart';

/// گاہک کے ڈیٹا تک رسائی کی پرت (Repository Pattern)
class CustomerRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insert(CustomerModel customer) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableCustomers, customer.toMap());
  }

  Future<int> update(CustomerModel customer) async {
    final db = await _dbHelper.database;
    return db.update(
      AppConstants.tableCustomers,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(AppConstants.tableCustomers, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CustomerModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableCustomers, orderBy: 'name ASC');
    return maps.map((m) => CustomerModel.fromMap(m)).toList();
  }

  Future<CustomerModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableCustomers, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CustomerModel.fromMap(maps.first);
  }

  Future<List<CustomerModel>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableCustomers,
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => CustomerModel.fromMap(m)).toList();
  }
}
