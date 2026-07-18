import 'package:flutter/material.dart';
import '../data/repositories/income_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/milk_repository.dart';
import '../data/repositories/bill_repository.dart';
import '../data/repositories/borrow_lend_repository.dart';
import '../data/repositories/rent_repository.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';

/// ڈیش بورڈ کے تمام اعدادوشمار اکٹھے کرنے والا پرووائیڈر
class DashboardProvider extends ChangeNotifier {
  final IncomeRepository _incomeRepo = IncomeRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final MilkRepository _milkRepo = MilkRepository();
  final BillRepository _billRepo = BillRepository();
  final BorrowLendRepository _borrowLendRepo = BorrowLendRepository();
  final RentRepository _rentRepo = RentRepository();

  double monthlyIncome = 0;
  double monthlyExpense = 0;
  double monthlyMilkBill = 0;
  double pendingBillsAmount = 0;
  double pendingReceivables = 0;
  double pendingPayables = 0;
  double currentBalance = 0;
  double totalIncomeAllTime = 0;
  double totalExpenseAllTime = 0;

  String rentStatusText = 'ریکارڈ موجود نہیں';
  double rentRemaining = 0;
  bool rentIsPaid = false;

  bool isLoading = true;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    final monthKey = DateFormatter.monthKey(DateTime.now());

    monthlyIncome = await _incomeRepo.getMonthlyTotal(monthKey);
    monthlyExpense = await _expenseRepo.getMonthlyTotal(monthKey);
    monthlyMilkBill = await _milkRepo.getMonthlyTotalAmount(monthKey);
    pendingBillsAmount = await _billRepo.getTotalPendingAmount();
    pendingReceivables = await _borrowLendRepo.getTotalRemainingByType(AppConstants.typeGiven);
    pendingPayables = await _borrowLendRepo.getTotalRemainingByType(AppConstants.typeReceived);

    totalIncomeAllTime = await _incomeRepo.getTotal();
    totalExpenseAllTime = await _expenseRepo.getTotal();

    // موجودہ بیلنس = کل آمدنی - کل اخراجات
    currentBalance = totalIncomeAllTime - totalExpenseAllTime;

    final rent = await _rentRepo.getByMonthKey(monthKey);
    if (rent == null) {
      rentStatusText = 'اس ماہ کا کرایہ درج نہیں';
      rentRemaining = 0;
      rentIsPaid = false;
    } else {
      rentIsPaid = rent.isPaid;
      rentRemaining = rent.remainingAmount;
      rentStatusText = rent.isPaid ? 'ادا شدہ' : 'باقی: Rs ${rent.remainingAmount.toStringAsFixed(0)}';
    }

    isLoading = false;
    notifyListeners();
  }
}
