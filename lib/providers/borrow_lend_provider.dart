import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/models/borrow_lend_model.dart';
import '../data/repositories/borrow_lend_repository.dart';

class BorrowLendProvider extends ChangeNotifier {
  final BorrowLendRepository _repo = BorrowLendRepository();

  List<BorrowLendModel> _givenList = [];
  List<BorrowLendModel> _receivedList = [];
  Map<int, double> _paidMap = {}; // id -> total paid so far
  bool _isLoading = false;

  List<BorrowLendModel> get givenList => _givenList;
  List<BorrowLendModel> get receivedList => _receivedList;
  bool get isLoading => _isLoading;

  double remainingFor(BorrowLendModel item) {
    final paid = _paidMap[item.id] ?? 0;
    return (item.amount - paid).clamp(0, double.infinity);
  }

  BorrowLendProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _givenList = await _repo.getByType(AppConstants.typeGiven);
    _receivedList = await _repo.getByType(AppConstants.typeReceived);

    _paidMap = {};
    for (final item in [..._givenList, ..._receivedList]) {
      if (item.id != null) {
        _paidMap[item.id!] = await _repo.getTotalPaid(item.id!);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(BorrowLendModel item) async {
    await _repo.insert(item);
    await loadAll();
  }

  Future<void> updateItem(BorrowLendModel item) async {
    await _repo.update(item);
    await loadAll();
  }

  Future<void> deleteItem(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<void> addPayment(BorrowLendPaymentModel payment) async {
    await _repo.insertPayment(payment);
    await loadAll();
  }

  Future<List<BorrowLendPaymentModel>> getPayments(int borrowLendId) {
    return _repo.getPayments(borrowLendId);
  }

  Future<double> getTotalReceivable() => _repo.getTotalRemainingByType(AppConstants.typeGiven);
  Future<double> getTotalPayable() => _repo.getTotalRemainingByType(AppConstants.typeReceived);

  Future<List<BorrowLendModel>> search(String query) => _repo.search(query);
}
