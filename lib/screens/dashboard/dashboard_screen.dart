import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';

import '../milk/milk_customers_screen.dart';
import '../income/income_screen.dart';
import '../expense/expense_screen.dart';
import '../bills/bills_screen.dart';
import '../borrow_lend/borrow_lend_screen.dart';
import '../rent/rent_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  Future<void> _refresh() async {
    await context.read<DashboardProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(AppStrings.appName),
            Text(
              DateFormatter.monthYear(DateTime.now()),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: dashboard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBalanceCard(dashboard),
                    const SizedBox(height: 16),
                    _buildStatGrid(dashboard, context),
                    const SizedBox(height: 8),
                    SectionHeader(title: AppStrings.overview),
                    _buildOverviewChart(dashboard),
                    const SizedBox(height: 8),
                    SectionHeader(title: AppStrings.quickActions),
                    _buildQuickActions(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(DashboardProvider dashboard) {
    final isPositive = dashboard.currentBalance >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: AppColors.balanceGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: Colors.white,
              ),
              const Text(
                AppStrings.currentBalance,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            CurrencyFormatter.format(dashboard.currentBalance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(DashboardProvider dashboard, BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        StatCard(
          title: AppStrings.monthlyIncome,
          value: CurrencyFormatter.format(dashboard.monthlyIncome),
          icon: Icons.arrow_downward_rounded,
          gradientColors: AppColors.incomeGradient,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeScreen())),
        ),
        StatCard(
          title: AppStrings.monthlyExpense,
          value: CurrencyFormatter.format(dashboard.monthlyExpense),
          icon: Icons.arrow_upward_rounded,
          gradientColors: AppColors.expenseGradient,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen())),
        ),
        StatCard(
          title: AppStrings.monthlyMilkBill,
          value: CurrencyFormatter.format(dashboard.monthlyMilkBill),
          icon: Icons.local_drink_rounded,
          gradientColors: AppColors.milkGradient,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MilkCustomersScreen())),
        ),
        StatCard(
          title: AppStrings.pendingBills,
          value: CurrencyFormatter.format(dashboard.pendingBillsAmount),
          icon: Icons.receipt_long_rounded,
          gradientColors: AppColors.billsGradient,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillsScreen())),
        ),
        StatCard(
          title: AppStrings.pendingReceivables,
          value: CurrencyFormatter.format(dashboard.pendingReceivables),
          icon: Icons.call_received_rounded,
          gradientColors: AppColors.receivableGradient,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BorrowLendScreen())),
        ),
        StatCard(
          title: AppStrings.pendingPayables,
          value: CurrencyFormatter.format(dashboard.pendingPayables),
          icon: Icons.call_made_rounded,
          gradientColors: AppColors.payableGradient,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BorrowLendScreen())),
        ),
        StatCard(
          title: AppStrings.shopRentStatus,
          value: dashboard.rentStatusText,
          icon: Icons.storefront_rounded,
          gradientColors: AppColors.rentGradient,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentScreen())),
        ),
      ],
    );
  }

  Widget _buildOverviewChart(DashboardProvider dashboard) {
    final maxVal = [
      dashboard.monthlyIncome,
      dashboard.monthlyExpense,
      dashboard.monthlyMilkBill,
    ].fold<double>(1, (prev, el) => el > prev ? el : prev);

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = [AppStrings.income, AppStrings.expense, AppStrings.milk];
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(labels[idx], style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: dashboard.monthlyIncome, color: AppColors.income, width: 28, borderRadius: BorderRadius.circular(6)),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: dashboard.monthlyExpense, color: AppColors.expense, width: 28, borderRadius: BorderRadius.circular(6)),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: dashboard.monthlyMilkBill, color: AppColors.milkGradient.first, width: 28, borderRadius: BorderRadius.circular(6)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(AppStrings.milk, Icons.local_drink_rounded, AppColors.milkGradient.first,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MilkCustomersScreen()))),
      _QuickAction(AppStrings.income, Icons.attach_money_rounded, AppColors.income,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeScreen()))),
      _QuickAction(AppStrings.expense, Icons.money_off_rounded, AppColors.expense,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen()))),
      _QuickAction(AppStrings.bills, Icons.receipt_long_rounded, AppColors.billsGradient.first,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillsScreen()))),
      _QuickAction(AppStrings.borrowLend, Icons.handshake_rounded, AppColors.receivableGradient.first,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BorrowLendScreen()))),
      _QuickAction(AppStrings.shopRent, Icons.storefront_rounded, AppColors.rentGradient.first,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentScreen()))),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: actions.map((a) => _buildActionTile(a)).toList(),
    );
  }

  Widget _buildActionTile(_QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: action.color.withOpacity(0.15),
              radius: 22,
              child: Icon(action.icon, color: action.color),
            ),
            const SizedBox(height: 8),
            Text(action.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _QuickAction(this.label, this.icon, this.color, this.onTap);
}
