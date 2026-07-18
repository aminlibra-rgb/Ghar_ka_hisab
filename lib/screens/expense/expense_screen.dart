import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/confirm_dialog.dart';
import 'add_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ExpenseProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final total = provider.expenses.fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.expense)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.expenseGradient),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.money_off_rounded, color: Colors.white, size: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(CurrencyFormatter.format(total),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('کل اخراجات', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.expenses.isEmpty
                      ? const EmptyState(message: 'کوئی اخراجات درج نہیں')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: provider.expenses.length,
                          itemBuilder: (context, index) {
                            final expense = provider.expenses[index];
                            return TransactionTile(
                              title: expense.category,
                              category: expense.notes.isEmpty ? expense.category : expense.notes,
                              date: expense.date,
                              amount: expense.amount,
                              amountColor: AppColors.expense,
                              icon: Icons.arrow_upward_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddExpenseScreen(existing: expense)),
                              ),
                              onDelete: () async {
                                final confirm = await showConfirmDialog(context);
                                if (confirm && expense.id != null) {
                                  await provider.deleteExpense(expense.id!);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
