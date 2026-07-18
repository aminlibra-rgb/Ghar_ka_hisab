import 'package:flutter/material.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';
import '../core/utils/date_formatter.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _expenses = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadByMonth(String monthKey) async {
    _isLoading = true;
    notifyListeners();
    _expenses = await _repo.getByMonth(monthKey);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _repo.insert(expense);
    await loadAll();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _repo.update(expense);
    await loadAll();
  }

  Future<void> deleteExpense(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<double> getCurrentMonthTotal() {
    return _repo.getMonthlyTotal(DateFormatter.monthKey(DateTime.now()));
  }

  Future<double> getTotal() => _repo.getTotal();

  Future<List<ExpenseModel>> search(String query) => _repo.search(query);

  Future<Map<String, double>> getCategoryTotalsForMonth(String monthKey) {
    return _repo.getCategoryTotalsForMonth(monthKey);
  }
}
