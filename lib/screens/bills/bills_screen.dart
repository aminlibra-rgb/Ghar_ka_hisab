import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/bill_model.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';
import 'add_bill_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BillProvider>().loadAll());
  }

  void _showMarkPaidDialog(BillModel bill) {
    final provider = context.read<BillProvider>();
    final controller = TextEditingController(text: bill.remainingAmount.toStringAsFixed(0));
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.recordPayment, textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppStrings.totalAmount}: ${CurrencyFormatter.format(bill.totalAmount)}', textAlign: TextAlign.right),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: AppStrings.paidAmount, prefixText: 'Rs '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? bill.paidAmount;
              await provider.markPayment(bill, amount, paymentDate);
              if (mounted) Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final pendingTotal = provider.pendingBills.fold<double>(0, (s, b) => s + b.remainingAmount);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.bills)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.billsGradient),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(CurrencyFormatter.format(pendingTotal),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text(AppStrings.pendingBills, style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.bills.isEmpty
                      ? const EmptyState(message: 'کوئی بل موجود نہیں')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: provider.bills.length,
                          itemBuilder: (context, index) {
                            final bill = provider.bills[index];
                            final daysLeft = DateFormatter.daysUntil(bill.dueDate);
                            return Card(
                              child: ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddBillScreen(existing: bill)),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.billsGradient.first.withOpacity(0.15),
                                  child: Icon(_billIcon(bill.billType), color: AppColors.billsGradient.first, size: 20),
                                ),
                                title: Text(bill.billName, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${AppStrings.dueDate}: ${DateFormatter.display(bill.dueDate)}'
                                      '${!bill.isPaid && daysLeft >= 0 ? ' ($daysLeft دن باقی)' : ''}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: !bill.isPaid && daysLeft <= 3 ? AppColors.danger : null,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge(isPaid: bill.isPaid),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyFormatter.format(bill.remainingAmount),
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (!bill.isPaid)
                                      TextButton(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                        onPressed: () => _showMarkPaidDialog(bill),
                                        child: const Text('ادا کریں', style: TextStyle(fontSize: 12)),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBillScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _billIcon(String type) {
    switch (type) {
      case AppStrings.billTypeElectricity:
        return Icons.bolt_rounded;
      case AppStrings.billTypeGas:
        return Icons.local_fire_department_rounded;
      case AppStrings.billTypeWater:
        return Icons.water_drop_rounded;
      case AppStrings.billTypeInternet:
        return Icons.wifi_rounded;
      case AppStrings.billTypeMobile:
        return Icons.phone_android_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }
}
