import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/income_model.dart';
import '../../providers/income_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/confirm_dialog.dart';
import 'add_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<IncomeProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncomeProvider>();
    final total = provider.incomes.fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.income)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.incomeGradient),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.attach_money_rounded, color: Colors.white, size: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(CurrencyFormatter.format(total),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('کل آمدنی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.incomes.isEmpty
                      ? const EmptyState(message: 'کوئی آمدنی درج نہیں')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: provider.incomes.length,
                          itemBuilder: (context, index) {
                            final income = provider.incomes[index];
                            return TransactionTile(
                              title: income.title,
                              category: income.category,
                              date: income.date,
                              amount: income.amount,
                              amountColor: AppColors.income,
                              icon: Icons.arrow_downward_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddIncomeScreen(existing: income)),
                              ),
                              onDelete: () async {
                                final confirm = await showConfirmDialog(context);
                                if (confirm && income.id != null) {
                                  await provider.deleteIncome(income.id!);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
