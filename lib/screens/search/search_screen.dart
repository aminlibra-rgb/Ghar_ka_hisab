import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/borrow_lend_provider.dart';
import '../../data/repositories/customer_repository.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _customerRepo = CustomerRepository();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'تلاش کریں... (نام، بل، رقم)',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ),
      body: _query.isEmpty
          ? const EmptyState(message: 'تلاش کرنے کے لیے کچھ لکھیں', icon: Icons.search_rounded)
          : FutureBuilder<_SearchResults>(
              future: _performSearch(_query),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final results = snapshot.data!;
                if (results.isEmpty) {
                  return const EmptyState(message: 'کوئی نتیجہ نہیں ملا', icon: Icons.search_off_rounded);
                }
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (results.customers.isNotEmpty) _buildSection(AppStrings.customers, results.customers.map((c) => _resultTile(c.name, c.phone, Icons.person_outline, AppColors.milkGradient.first)).toList()),
                    if (results.incomes.isNotEmpty) _buildSection(AppStrings.income, results.incomes.map((i) => _resultTile(i.title, '${DateFormatter.display(i.date)} • ${CurrencyFormatter.format(i.amount)}', Icons.arrow_downward_rounded, AppColors.income)).toList()),
                    if (results.expenses.isNotEmpty) _buildSection(AppStrings.expense, results.expenses.map((e) => _resultTile(e.category, '${DateFormatter.display(e.date)} • ${CurrencyFormatter.format(e.amount)}', Icons.arrow_upward_rounded, AppColors.expense)).toList()),
                    if (results.bills.isNotEmpty) _buildSection(AppStrings.bills, results.bills.map((b) => _resultTile(b.billName, '${DateFormatter.display(b.dueDate)} • ${CurrencyFormatter.format(b.remainingAmount)}', Icons.receipt_long_rounded, AppColors.billsGradient.first)).toList()),
                    if (results.people.isNotEmpty) _buildSection(AppStrings.borrowLend, results.people.map((p) => _resultTile(p.personName, '${DateFormatter.display(p.date)} • ${CurrencyFormatter.format(p.amount)}', Icons.handshake_outlined, AppColors.receivableGradient.first)).toList()),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        ...tiles,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _resultTile(String title, String subtitle, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 20)),
        title: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, textAlign: TextAlign.right),
      ),
    );
  }

  Future<_SearchResults> _performSearch(String query) async {
    final customers = await _customerRepo.search(query);
    final incomes = await context.read<IncomeProvider>().search(query);
    final expenses = await context.read<ExpenseProvider>().search(query);
    final bills = await context.read<BillProvider>().search(query);
    final people = await context.read<BorrowLendProvider>().search(query);

    return _SearchResults(
      customers: customers,
      incomes: incomes,
      expenses: expenses,
      bills: bills,
      people: people,
    );
  }
}

class _SearchResults {
  final List customers;
  final List incomes;
  final List expenses;
  final List bills;
  final List people;

  _SearchResults({
    required this.customers,
    required this.incomes,
    required this.expenses,
    required this.bills,
    required this.people,
  });

  bool get isEmpty =>
      customers.isEmpty && incomes.isEmpty && expenses.isEmpty && bills.isEmpty && people.isEmpty;
}
