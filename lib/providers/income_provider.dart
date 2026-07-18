import 'package:flutter/material.dart';
import '../data/models/income_model.dart';
import '../data/repositories/income_repository.dart';
import '../core/utils/date_formatter.dart';

class IncomeProvider extends ChangeNotifier {
  final IncomeRepository _repo = IncomeRepository();

  List<IncomeModel> _incomes = [];
  bool _isLoading = false;

  List<IncomeModel> get incomes => _incomes;
  bool get isLoading => _isLoading;

  IncomeProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _incomes = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadByMonth(String monthKey) async {
    _isLoading = true;
    notifyListeners();
    _incomes = await _repo.getByMonth(monthKey);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addIncome(IncomeModel income) async {
    await _repo.insert(income);
    await loadAll();
  }

  Future<void> updateIncome(IncomeModel income) async {
    await _repo.update(income);
    await loadAll();
  }

  Future<void> deleteIncome(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<double> getCurrentMonthTotal() {
    return _repo.getMonthlyTotal(DateFormatter.monthKey(DateTime.now()));
  }

  Future<double> getTotal() => _repo.getTotal();

  Future<List<IncomeModel>> search(String query) => _repo.search(query);

  Future<Map<String, double>> getCategoryTotalsForMonth(String monthKey) {
    return _repo.getCategoryTotalsForMonth(monthKey);
  }
}
