import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/models/bill_model.dart';
import '../data/repositories/bill_repository.dart';
import '../services/notification_service.dart';

class BillProvider extends ChangeNotifier {
  final BillRepository _repo = BillRepository();
  final NotificationService _notificationService = NotificationService();

  List<BillModel> _bills = [];
  bool _isLoading = false;

  List<BillModel> get bills => _bills;
  List<BillModel> get pendingBills => _bills.where((b) => !b.isPaid).toList();
  bool get isLoading => _isLoading;

  BillProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _bills = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBill(BillModel bill) async {
    final id = await _repo.insert(bill);
    final saved = bill.copyWith(id: id);
    if (!saved.isPaid) {
      await _notificationService.scheduleBillReminder(saved);
    }
    await loadAll();
  }

  Future<void> updateBill(BillModel bill) async {
    await _repo.update(bill);
    if (bill.id != null) {
      await _notificationService.cancelBillReminder(bill.id!);
      if (!bill.isPaid) {
        await _notificationService.scheduleBillReminder(bill);
      }
    }
    await loadAll();
  }

  /// بل کی ادائیگی ریکارڈ کرنا اور حالت اپڈیٹ کرنا
  Future<void> markPayment(BillModel bill, double paidAmount, DateTime paymentDate) async {
    final newPaid = paidAmount;
    final status = newPaid >= bill.totalAmount ? AppConstants.statusPaid : AppConstants.statusPending;
    final updated = bill.copyWith(
      paidAmount: newPaid,
      paymentDate: paymentDate,
      status: status,
    );
    await updateBill(updated);
  }

  Future<void> deleteBill(int id) async {
    await _notificationService.cancelBillReminder(id);
    await _repo.delete(id);
    await loadAll();
  }

  Future<double> getTotalPendingAmount() => _repo.getTotalPendingAmount();

  Future<List<BillModel>> search(String query) => _repo.search(query);

  Future<List<BillModel>> getUpcoming({int withinDays = 3}) => _repo.getUpcoming(withinDays: withinDays);
}
