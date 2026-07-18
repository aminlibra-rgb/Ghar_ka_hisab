import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/milk_record_model.dart';
import '../../data/models/milk_payment_model.dart';
import '../../providers/milk_provider.dart';
import '../../services/pdf_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/confirm_dialog.dart';

class MilkCustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;
  const MilkCustomerDetailScreen({super.key, required this.customer});

  @override
  State<MilkCustomerDetailScreen> createState() => _MilkCustomerDetailScreenState();
}

class _MilkCustomerDetailScreenState extends State<MilkCustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilkProvider>().loadCustomerDetails(widget.customer.id!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddRecordDialog() {
    final provider = context.read<MilkProvider>();
    final qtyController = TextEditingController();
    final priceController = TextEditingController(text: provider.milkPrice.toStringAsFixed(0));
    DateTime date = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('دودھ کا اندراج', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDateField(
                label: AppStrings.date,
                selectedDate: date,
                onDateSelected: (d) => setStateDialog(() => date = d),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: AppStrings.quantityLiters),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: AppStrings.milkPricePerLiter),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
            ElevatedButton(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text);
                final price = double.tryParse(priceController.text);
                if (qty == null || price == null) return;
                await provider.addRecord(MilkRecordModel(
                  customerId: widget.customer.id!,
                  date: date,
                  quantityLiters: qty,
                  pricePerLiter: price,
                ));
                if (mounted) Navigator.pop(context);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    final provider = context.read<MilkProvider>();
    final amountController = TextEditingController();
    DateTime date = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(AppStrings.recordPayment, textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDateField(
                label: AppStrings.date,
                selectedDate: date,
                onDateSelected: (d) => setStateDialog(() => date = d),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: AppStrings.amount, prefixText: 'Rs '),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null) return;
                await provider.addPayment(MilkPaymentModel(
                  customerId: widget.customer.id!,
                  date: date,
                  amount: amount,
                ));
                if (mounted) Navigator.pop(context);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportStatementPdf() async {
    final provider = context.read<MilkProvider>();
    final monthKey = DateFormatter.monthKey(_selectedMonth);
    final records = await provider.getRecordsByMonth(monthKey, customerId: widget.customer.id);

    final rows = records
        .map((r) => [
              DateFormatter.display(r.date),
              r.quantityLiters.toStringAsFixed(1),
              CurrencyFormatter.formatDecimal(r.pricePerLiter),
              CurrencyFormatter.format(r.totalAmount),
            ])
        .toList();

    final total = records.fold<double>(0, (sum, r) => sum + r.totalAmount);

    final bytes = await PdfService.generateTableReport(
      reportTitle: '${widget.customer.name} - ${AppStrings.monthlyStatement}',
      subtitle: DateFormatter.monthYear(_selectedMonth),
      headers: [AppStrings.date, AppStrings.quantityLiters, AppStrings.milkPricePerLiter, AppStrings.amount].reversed.toList(),
      rows: rows.map((r) => r.reversed.toList()).toList(),
      footerNote: '${AppStrings.monthlyBill}: ${CurrencyFormatter.format(total)}',
    );

    await PdfService.printOrShare(bytes, 'milk_statement_${widget.customer.name}_$monthKey.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MilkProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'یومیہ ریکارڈ'),
            Tab(text: 'ادائیگیاں'),
            Tab(text: 'گوشوارہ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsTab(provider),
          _buildPaymentsTab(provider),
          _buildStatementTab(provider),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(onPressed: _showAddPaymentDialog, child: const Icon(Icons.payments_outlined))
          : FloatingActionButton(onPressed: _showAddRecordDialog, child: const Icon(Icons.add)),
    );
  }

  Widget _buildRecordsTab(MilkProvider provider) {
    final records = provider.selectedCustomerRecords;
    if (records.isEmpty) return const EmptyState(message: 'کوئی ریکارڈ موجود نہیں');
    final total = records.fold<double>(0, (s, r) => s + r.totalAmount);
    return Column(
      children: [
        _summaryBar('کل بل', total, AppColors.milkGradient.first),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.milkGradient.first.withOpacity(0.15),
                    child: Icon(Icons.local_drink, color: AppColors.milkGradient.first, size: 18),
                  ),
                  title: Text('${r.quantityLiters} لیٹر', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormatter.display(r.date), textAlign: TextAlign.right),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(CurrencyFormatter.format(r.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showConfirmDialog(context);
                          if (confirm && r.id != null) {
                            await provider.deleteRecord(r.id!, widget.customer.id!);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        ),
                      ),
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

  Widget _buildPaymentsTab(MilkProvider provider) {
    final payments = provider.selectedCustomerPayments;
    final totalPaid = payments.fold<double>(0, (s, p) => s + p.amount);
    final totalBill = provider.selectedCustomerRecords.fold<double>(0, (s, r) => s + r.totalAmount);
    final remaining = totalBill - totalPaid;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _summaryBar(AppStrings.remainingBalance, remaining, AppColors.danger)),
          ],
        ),
        Expanded(
          child: payments.isEmpty
              ? const EmptyState(message: 'کوئی ادائیگی موجود نہیں')
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final p = payments[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0x1A2E7D32),
                          child: Icon(Icons.check_circle_outline, color: AppColors.paid, size: 20),
                        ),
                        title: Text(CurrencyFormatter.format(p.amount), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormatter.display(p.date), textAlign: TextAlign.right),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatementTab(MilkProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedMonth,
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2100),
                      initialDatePickerMode: DatePickerMode.year,
                    );
                    if (picked != null) setState(() => _selectedMonth = picked);
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(DateFormatter.monthYear(_selectedMonth)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _exportStatementPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text(AppStrings.exportPdf),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<MilkRecordModel>>(
              future: provider.getRecordsByMonth(DateFormatter.monthKey(_selectedMonth), customerId: widget.customer.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final records = snapshot.data!;
                if (records.isEmpty) return const EmptyState(message: 'اس مہینے کا کوئی ریکارڈ نہیں');
                final total = records.fold<double>(0, (s, r) => s + r.totalAmount);
                return Column(
                  children: [
                    _summaryBar(AppStrings.monthlyBill, total, AppColors.milkGradient.first),
                    Expanded(
                      child: ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final r = records[index];
                          return ListTile(
                            title: Text('${r.quantityLiters} لیٹر × ${CurrencyFormatter.formatDecimal(r.pricePerLiter)}', textAlign: TextAlign.right),
                            subtitle: Text(DateFormatter.display(r.date), textAlign: TextAlign.right),
                            trailing: Text(CurrencyFormatter.format(r.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBar(String label, double value, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(CurrencyFormatter.format(value), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
