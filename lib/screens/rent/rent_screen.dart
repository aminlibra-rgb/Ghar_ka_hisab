import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/rent_model.dart';
import '../../providers/rent_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_date_field.dart';

class RentScreen extends StatefulWidget {
  const RentScreen({super.key});

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<RentProvider>().loadAll());
  }

  void _showSetupRentDialog(RentProvider provider) {
    final current = provider.currentMonthRent;
    final rentController = TextEditingController(
      text: current != null ? current.monthlyRent.toStringAsFixed(0) : '',
    );
    DateTime dueDate = current?.dueDate ?? DateTime(DateTime.now().year, DateTime.now().month, 5);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('${DateFormatter.monthYear(DateTime.now())} کا کرایہ', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: AppStrings.monthlyRent, prefixText: 'Rs '),
              ),
              const SizedBox(height: 12),
              CustomDateField(
                label: AppStrings.dueDate,
                selectedDate: dueDate,
                onDateSelected: (d) => setStateDialog(() => dueDate = d),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(rentController.text);
                if (amount == null) return;
                await provider.addOrUpdateRent(RentModel(
                  monthKey: DateFormatter.monthKey(DateTime.now()),
                  monthlyRent: amount,
                  paidAmount: current?.paidAmount ?? 0,
                  dueDate: dueDate,
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

  void _showPaymentDialog(RentProvider provider, RentModel rent) {
    final controller = TextEditingController(text: rent.remainingAmount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.recordPayment, textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(labelText: AppStrings.paidAmount, prefixText: 'Rs '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () async {
              final additional = double.tryParse(controller.text) ?? 0;
              final newTotal = (rent.paidAmount + additional).clamp(0, rent.monthlyRent).toDouble();
              await provider.recordPayment(rent, newTotal, DateTime.now());
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
    final provider = context.watch<RentProvider>();
    final rent = provider.currentMonthRent;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.shopRent)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.rentGradient),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: rent == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                            const SizedBox(height: 10),
                            const Text('اس ماہ کا کرایہ درج نہیں', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.rentGradient.first),
                              onPressed: () => _showSetupRentDialog(provider),
                              child: const Text('کرایہ درج کریں'),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StatusBadge(isPaid: rent.isPaid),
                                Text(DateFormatter.monthYear(DateTime.now()),
                                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(CurrencyFormatter.format(rent.monthlyRent),
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                            const Text(AppStrings.monthlyRent, style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${AppStrings.dueDate}: ${DateFormatter.display(rent.dueDate)}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                Text('باقی: ${CurrencyFormatter.format(rent.remainingAmount)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                                    onPressed: () => _showSetupRentDialog(provider),
                                    child: const Text(AppStrings.edit, style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (!rent.isPaid)
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.rentGradient.first),
                                      onPressed: () => _showPaymentDialog(provider, rent),
                                      child: const Text('ادائیگی'),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                const Text(AppStrings.paymentHistory, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (provider.rentHistory.isEmpty)
                  const EmptyState(message: 'کوئی ریکارڈ موجود نہیں')
                else
                  ...provider.rentHistory.map((r) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.rentGradient.first.withOpacity(0.15),
                            child: Icon(Icons.storefront_rounded, color: AppColors.rentGradient.first, size: 18),
                          ),
                          title: Text(r.monthKey, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${AppStrings.dueDate}: ${DateFormatter.display(r.dueDate)}', textAlign: TextAlign.right),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(CurrencyFormatter.format(r.monthlyRent), style: const TextStyle(fontWeight: FontWeight.bold)),
                              StatusBadge(isPaid: r.isPaid),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
    );
  }
}
