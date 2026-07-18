import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/borrow_lend_model.dart';
import '../../providers/borrow_lend_provider.dart';
import '../../widgets/empty_state.dart';
import 'add_borrow_lend_screen.dart';
import 'person_detail_screen.dart';

class BorrowLendScreen extends StatefulWidget {
  const BorrowLendScreen({super.key});

  @override
  State<BorrowLendScreen> createState() => _BorrowLendScreenState();
}

class _BorrowLendScreenState extends State<BorrowLendScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BorrowLendProvider>().loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BorrowLendProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.borrowLend),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: AppStrings.moneyGiven),
            Tab(text: AppStrings.moneyReceived),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(provider, provider.givenList, AppColors.receivableGradient.first),
                _buildList(provider, provider.receivedList, AppColors.payableGradient.first),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddBorrowLendScreen(isGiven: _tabController.index == 0),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BorrowLendProvider provider, List<BorrowLendModel> items, Color color) {
    if (items.isEmpty) return const EmptyState(message: 'کوئی ریکارڈ موجود نہیں', icon: Icons.handshake_outlined);

    final totalRemaining = items.fold<double>(0, (s, item) => s + provider.remainingFor(item));

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: color),
              Text(
                CurrencyFormatter.format(totalRemaining),
                style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final remaining = provider.remainingFor(item);
              return Card(
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PersonDetailScreen(item: item)),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Text(
                      item.personName.isNotEmpty ? item.personName[0] : '?',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(item.personName, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormatter.display(item.date), textAlign: TextAlign.right),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(CurrencyFormatter.format(remaining), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      Text('کل: ${CurrencyFormatter.format(item.amount)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
