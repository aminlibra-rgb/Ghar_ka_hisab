import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/borrow_lend_model.dart';
import '../../providers/borrow_lend_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/confirm_dialog.dart';

class PersonDetailScreen extends StatefulWidget {
  final BorrowLendModel item;
  const PersonDetailScreen({super.key, required this.item});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  List<BorrowLendPaymentModel> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    final provider = context.read<BorrowLendProvider>();
    _payments = await provider.getPayments(widget.item.id!);
    setState(() => _loading = false);
  }

  void _showAddPaymentDialog() {
    final controller = TextEditingController();
    DateTime date = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(AppStrings.partialPayment, textAlign: TextAlign.right),
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
                controller: controller,
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
                final amount = double.tryParse(controller.text);
                if (amount == null || widget.item.id == null) return;
                await context.read<BorrowLendProvider>().addPayment(
                      BorrowLendPaymentModel(borrowLendId: widget.item.id!, amount: amount, date: date),
                    );
                if (mounted) Navigator.pop(context);
                _loadPayments();
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BorrowLendProvider>();
    final remaining = provider.remainingFor(widget.item);
    final isGiven = widget.item.type == AppConstants.typeGiven;
    final color = isGiven ? AppColors.receivableGradient.first : AppColors.payableGradient.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.personName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showConfirmDialog(context);
              if (confirm && widget.item.id != null) {
                await context.read<BorrowLendProvider>().deleteItem(widget.item.id!);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.info_outline, color: color),
                          Text(isGiven ? AppStrings.moneyGiven : AppStrings.moneyReceived,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoRow(AppStrings.amount, CurrencyFormatter.format(widget.item.amount)),
                      _infoRow(AppStrings.date, DateFormatter.display(widget.item.date)),
                      if (widget.item.phoneNumber.isNotEmpty) _infoRow(AppStrings.phoneNumber, widget.item.phoneNumber),
                      _infoRow(AppStrings.remainingBalance, CurrencyFormatter.format(remaining), valueColor: color),
                      if (widget.item.notes.isNotEmpty) _infoRow(AppStrings.notes, widget.item.notes),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: remaining > 0 ? _showAddPaymentDialog : null,
                      icon: const Icon(Icons.add),
                      label: const Text(AppStrings.partialPayment),
                    ),
                    Text(AppStrings.history, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                if (_payments.isEmpty)
                  const EmptyState(message: 'کوئی ادائیگی درج نہیں')
                else
                  ..._payments.map((p) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.check_circle_outline, color: AppColors.paid),
                          title: Text(CurrencyFormatter.format(p.amount), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormatter.display(p.date), textAlign: TextAlign.right),
                        ),
                      )),
              ],
            ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
