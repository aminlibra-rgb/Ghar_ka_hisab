import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/bill_model.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/confirm_dialog.dart';

class AddBillScreen extends StatefulWidget {
  final BillModel? existing;
  const AddBillScreen({super.key, this.existing});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _totalController;
  late TextEditingController _paidController;
  late TextEditingController _notesController;
  late String _billType;
  late DateTime _dueDate;

  final _types = [
    AppStrings.billTypeElectricity,
    AppStrings.billTypeGas,
    AppStrings.billTypeWater,
    AppStrings.billTypeInternet,
    AppStrings.billTypeMobile,
    AppStrings.billTypeOther,
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.billName ?? '');
    _totalController = TextEditingController(text: e != null ? e.totalAmount.toStringAsFixed(0) : '');
    _paidController = TextEditingController(text: e != null ? e.paidAmount.toStringAsFixed(0) : '0');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _billType = e?.billType ?? _types.first;
    _dueDate = e?.dueDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _paidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<BillProvider>();
    final total = double.parse(_totalController.text.trim());
    final paid = double.tryParse(_paidController.text.trim()) ?? 0;
    final model = BillModel(
      id: widget.existing?.id,
      billName: _nameController.text.trim(),
      billType: _billType,
      totalAmount: total,
      paidAmount: paid,
      dueDate: _dueDate,
      paymentDate: paid > 0 ? DateTime.now() : null,
      notes: _notesController.text.trim(),
    );
    if (widget.existing == null) {
      await provider.addBill(model);
    } else {
      await provider.updateBill(model);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showConfirmDialog(context);
    if (confirm && widget.existing?.id != null) {
      await context.read<BillProvider>().deleteBill(widget.existing!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? AppStrings.bills : AppStrings.edit),
        actions: [
          if (widget.existing != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: AppStrings.billName,
              controller: _nameController,
              validator: Validators.requiredText,
              icon: Icons.receipt_outlined,
            ),
            const SizedBox(height: 14),
            CustomDropdown(
              label: AppStrings.category,
              value: _billType,
              items: _types,
              onChanged: (v) => setState(() => _billType = v ?? _billType),
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: AppStrings.totalAmount,
              controller: _totalController,
              validator: Validators.amount,
              isNumber: true,
              icon: Icons.attach_money_rounded,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: AppStrings.paidAmount,
              controller: _paidController,
              validator: Validators.optionalAmount,
              isNumber: true,
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 14),
            CustomDateField(
              label: AppStrings.dueDate,
              selectedDate: _dueDate,
              onDateSelected: (d) => setState(() => _dueDate = d),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: AppStrings.notes,
              controller: _notesController,
              maxLines: 3,
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text(AppStrings.save)),
          ],
        ),
      ),
    );
  }
}
