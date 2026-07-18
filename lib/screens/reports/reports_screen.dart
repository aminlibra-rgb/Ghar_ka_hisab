import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/milk_provider.dart';
import '../../providers/bill_provider.dart';
import '../../services/pdf_service.dart';

enum ReportRange { daily, weekly, monthly, yearly }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportRange _range = ReportRange.monthly;
  DateTime _refDate = DateTime.now();

  DateTimeRange get _dateRange {
    switch (_range) {
      case ReportRange.daily:
        return DateTimeRange(start: _refDate, end: _refDate);
      case ReportRange.weekly:
        final start = _refDate.subtract(Duration(days: _refDate.weekday - 1));
        return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
      case ReportRange.monthly:
        final start = DateTime(_refDate.year, _refDate.month, 1);
        final end = DateTime(_refDate.year, _refDate.month + 1, 0);
        return DateTimeRange(start: start, end: end);
      case ReportRange.yearly:
        return DateTimeRange(start: DateTime(_refDate.year, 1, 1), end: DateTime(_refDate.year, 12, 31));
    }
  }

  String get _rangeLabel {
    switch (_range) {
      case ReportRange.daily:
        return AppStrings.dailyReport;
      case ReportRange.weekly:
        return AppStrings.weeklyReport;
      case ReportRange.monthly:
        return AppStrings.monthlyReport;
      case ReportRange.yearly:
        return AppStrings.yearlyReport;
    }
  }

  Future<Map<String, double>> _loadTotals() async {
    final range = _dateRange;
    final startIso = DateFormatter.toDbFormat(range.start);
    final endIso = DateFormatter.toDbFormat(range.end);

    final incomeRepo = context.read<IncomeProvider>();
    final expenseRepo = context.read<ExpenseProvider>();
    final milkProvider = context.read<MilkProvider>();
    final billProvider = context.read<BillProvider>();

    final incomes = await incomeRepo.search('');
    final expenses = await expenseRepo.search('');

    double incomeTotal = 0;
    for (final i in incomes) {
      if (DateFormatter.toDbFormat(i.date).compareTo(startIso) >= 0 &&
          DateFormatter.toDbFormat(i.date).compareTo(endIso) <= 0) {
        incomeTotal += i.amount;
      }
    }
    double expenseTotal = 0;
    for (final e in expenses) {
      if (DateFormatter.toDbFormat(e.date).compareTo(startIso) >= 0 &&
          DateFormatter.toDbFormat(e.date).compareTo(endIso) <= 0) {
        expenseTotal += e.amount;
      }
    }

    final milkTotal = await milkProvider.getMonthlyTotal(DateFormatter.monthKey(_refDate));
    final pendingBills = await billProvider.getTotalPendingAmount();

    return {
      'income': incomeTotal,
      'expense': expenseTotal,
      'milk': milkTotal,
      'bills': pendingBills,
    };
  }

  Future<void> _exportPdf(Map<String, double> totals) async {
    final headers = [AppStrings.amount, 'قسم'].reversed.toList();
    final rows = [
      [AppStrings.income, CurrencyFormatter.format(totals['income'] ?? 0)].reversed.toList(),
      [AppStrings.expense, CurrencyFormatter.format(totals['expense'] ?? 0)].reversed.toList(),
      [AppStrings.milk, CurrencyFormatter.format(totals['milk'] ?? 0)].reversed.toList(),
      [AppStrings.bills, CurrencyFormatter.format(totals['bills'] ?? 0)].reversed.toList(),
    ];
    final net = (totals['income'] ?? 0) - (totals['expense'] ?? 0);

    final bytes = await PdfService.generateTableReport(
      reportTitle: _rangeLabel,
      subtitle: '${DateFormatter.display(_dateRange.start)} - ${DateFormatter.display(_dateRange.end)}',
      headers: headers,
      rows: rows,
      footerNote: 'خالص بچت: ${CurrencyFormatter.format(net)}',
    );
    await PdfService.printOrShare(bytes, 'report_${DateFormatter.toDbFormat(DateTime.now())}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reports)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRangeSelector(),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, double>>(
                future: _loadTotals(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final totals = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSummaryCards(totals),
                        const SizedBox(height: 20),
                        _buildPieChart(totals),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _exportPdf(totals),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text(AppStrings.exportPdf),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    return SegmentedButton<ReportRange>(
      segments: const [
        ButtonSegment(value: ReportRange.daily, label: Text(AppStrings.dailyReport, style: TextStyle(fontSize: 11))),
        ButtonSegment(value: ReportRange.weekly, label: Text(AppStrings.weeklyReport, style: TextStyle(fontSize: 11))),
        ButtonSegment(value: ReportRange.monthly, label: Text(AppStrings.monthlyReport, style: TextStyle(fontSize: 11))),
        ButtonSegment(value: ReportRange.yearly, label: Text(AppStrings.yearlyReport, style: TextStyle(fontSize: 11))),
      ],
      selected: {_range},
      onSelectionChanged: (selection) => setState(() => _range = selection.first),
    );
  }

  Widget _buildSummaryCards(Map<String, double> totals) {
    final net = (totals['income'] ?? 0) - (totals['expense'] ?? 0);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _miniCard(AppStrings.income, totals['income'] ?? 0, AppColors.income)),
            const SizedBox(width: 10),
            Expanded(child: _miniCard(AppStrings.expense, totals['expense'] ?? 0, AppColors.expense)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _miniCard(AppStrings.milk, totals['milk'] ?? 0, AppColors.milkGradient.first)),
            const SizedBox(width: 10),
            Expanded(child: _miniCard('خالص بچت', net, net >= 0 ? AppColors.income : AppColors.expense)),
          ],
        ),
      ],
    );
  }

  Widget _miniCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(CurrencyFormatter.format(value), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> totals) {
    final expense = totals['expense'] ?? 0;
    final milk = totals['milk'] ?? 0;
    final bills = totals['bills'] ?? 0;
    final total = expense + milk + bills;
    if (total <= 0) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('اس عرصے میں کوئی ڈیٹا موجود نہیں')),
      );
    }
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(value: expense, color: AppColors.expense, title: '${((expense / total) * 100).toStringAsFixed(0)}%', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: milk, color: AppColors.milkGradient.first, title: '${((milk / total) * 100).toStringAsFixed(0)}%', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: bills, color: AppColors.billsGradient.first, title: '${((bills / total) * 100).toStringAsFixed(0)}%', radius: 55, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
