import 'package:flutter/material.dart';
import '../data/models/customer_model.dart';
import '../data/models/milk_record_model.dart';
import '../data/models/milk_payment_model.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/milk_repository.dart';
import '../services/settings_service.dart';
import '../core/utils/date_formatter.dart';

/// دودھ کے ماڈیول کی مکمل حالت کا انتظام
class MilkProvider extends ChangeNotifier {
  final CustomerRepository _customerRepo = CustomerRepository();
  final MilkRepository _milkRepo = MilkRepository();
  final SettingsService _settingsService = SettingsService();

  List<CustomerModel> _customers = [];
  List<MilkRecordModel> _selectedCustomerRecords = [];
  List<MilkPaymentModel> _selectedCustomerPayments = [];
  double _milkPrice = 200.0;
  bool _isLoading = false;

  List<CustomerModel> get customers => _customers;
  List<MilkRecordModel> get selectedCustomerRecords => _selectedCustomerRecords;
  List<MilkPaymentModel> get selectedCustomerPayments => _selectedCustomerPayments;
  double get milkPrice => _milkPrice;
  bool get isLoading => _isLoading;

  MilkProvider() {
    _init();
  }

  Future<void> _init() async {
    _milkPrice = await _settingsService.getMilkPrice();
    await loadCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();
    _customers = await _customerRepo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setMilkPrice(double price) async {
    _milkPrice = price;
    await _settingsService.setMilkPrice(price);
    notifyListeners();
  }

  Future<void> addCustomer(String name, String phone) async {
    await _customerRepo.insert(CustomerModel(name: name, phone: phone));
    await loadCustomers();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _customerRepo.update(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await _customerRepo.delete(id);
    await loadCustomers();
  }

  Future<void> loadCustomerDetails(int customerId) async {
    _selectedCustomerRecords = await _milkRepo.getRecordsByCustomer(customerId);
    _selectedCustomerPayments = await _milkRepo.getPaymentsByCustomer(customerId);
    notifyListeners();
  }

  Future<void> addRecord(MilkRecordModel record) async {
    await _milkRepo.insertRecord(record);
    await loadCustomerDetails(record.customerId);
  }

  Future<void> updateRecord(MilkRecordModel record) async {
    await _milkRepo.updateRecord(record);
    await loadCustomerDetails(record.customerId);
  }

  Future<void> deleteRecord(int id, int customerId) async {
    await _milkRepo.deleteRecord(id);
    await loadCustomerDetails(customerId);
  }

  Future<void> addPayment(MilkPaymentModel payment) async {
    await _milkRepo.insertPayment(payment);
    await loadCustomerDetails(payment.customerId);
  }

  Future<double> getRemainingBalance(int customerId) {
    return _milkRepo.getRemainingBalance(customerId);
  }

  Future<double> getTotalBillByCustomer(int customerId) {
    return _milkRepo.getTotalBillByCustomer(customerId);
  }

  Future<double> getTotalPaidByCustomer(int customerId) {
    return _milkRepo.getTotalPaidByCustomer(customerId);
  }

  Future<List<MilkRecordModel>> getRecordsByMonth(String monthKey, {int? customerId}) {
    return _milkRepo.getRecordsByMonth(monthKey, customerId: customerId);
  }

  Future<double> getMonthlyTotal(String monthKey) {
    return _milkRepo.getMonthlyTotalAmount(monthKey);
  }

  Future<double> getCurrentMonthTotalBill() {
    return _milkRepo.getCurrentMonthTotalBill();
  }

  /// آج کی تاریخ کے حساب سے یومیہ کل مقدار اور رقم
  Future<Map<String, double>> getTodayTotals() async {
    final today = DateFormatter.toDbFormat(DateTime.now());
    final records = await _milkRepo.getRecordsByDate(today);
    double totalLiters = 0;
    double totalAmount = 0;
    for (final r in records) {
      totalLiters += r.quantityLiters;
      totalAmount += r.totalAmount;
    }
    return {'liters': totalLiters, 'amount': totalAmount};
  }
}
