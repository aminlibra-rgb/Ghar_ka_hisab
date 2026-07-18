import 'package:flutter/material.dart';
import '../data/models/rent_model.dart';
import '../data/repositories/rent_repository.dart';
import '../services/notification_service.dart';
import '../core/utils/date_formatter.dart';

class RentProvider extends ChangeNotifier {
  final RentRepository _repo = RentRepository();
  final NotificationService _notificationService = NotificationService();

  List<RentModel> _rentHistory = [];
  RentModel? _currentMonthRent;
  bool _isLoading = false;

  List<RentModel> get rentHistory => _rentHistory;
  RentModel? get currentMonthRent => _currentMonthRent;
  bool get isLoading => _isLoading;

  RentProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _rentHistory = await _repo.getAll();
    final monthKey = DateFormatter.monthKey(DateTime.now());
    _currentMonthRent = await _repo.getByMonthKey(monthKey);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrUpdateRent(RentModel rent) async {
    final existing = await _repo.getByMonthKey(rent.monthKey);
    if (existing != null) {
      await _repo.update(rent.copyWith(id: existing.id));
    } else {
      await _repo.insert(rent);
    }
    if (!rent.isPaid) {
      await _notificationService.scheduleRentReminder(rent.dueDate, rent.remainingAmount);
    }
    await loadAll();
  }

  Future<void> recordPayment(RentModel rent, double newPaidAmount, DateTime paymentDate) async {
    final updated = rent.copyWith(paidAmount: newPaidAmount);
    await _repo.update(updated);
    await _repo.insertPayment(RentPaymentModel(
      rentId: rent.id!,
      amount: newPaidAmount - rent.paidAmount,
      date: paymentDate,
    ));
    await loadAll();
  }

  Future<void> deleteRent(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<List<RentPaymentModel>> getPayments(int rentId) => _repo.getPayments(rentId);
}
