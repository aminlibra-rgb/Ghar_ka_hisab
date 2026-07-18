import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_dropdown.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? existing;
  const AddExpenseScreen({super.key, this.existing});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late String _category;
  late DateTime _date;

  final _categories = [
    AppStrings.expenseCategoryGrocery,
    AppStrings.expenseCategoryElectricity,
    AppStrings.expenseCategoryGas,
    AppStrings.expenseCategoryWater,
    AppStrings.expenseCategoryInternet,
    AppStrings.expenseCategoryFuel,
    AppStrings.expenseCategoryMedical,
    AppStrings.expenseCategoryShopping,
    AppStrings.expenseCategoryEducation,
    AppStrings.expenseCategoryOther,
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountController = TextEditingController(text: e != null ? e.amount.toStringAsFixed(0) : '');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _category = e?.category ?? _categories.first;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ExpenseProvider>();
    final model = ExpenseModel(
      id: widget.existing?.id,
      amount: double.parse(_amountController.text.trim()),
      category: _category,
      date: _date,
      notes: _notesController.text.trim(),
    );
    if (widget.existing == null) {
      await provider.addExpense(model);
    } else {
      await provider.updateExpense(model);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? AppStrings.expense : AppStrings.edit)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: AppStrings.amount,
              controller: _amountController,
              validator: Validators.amount,
              isNumber: true,
              icon: Icons.attach_money_rounded,
            ),
            const SizedBox(height: 14),
            CustomDropdown(
              label: AppStrings.category,
              value: _category,
              items: _categories,
              onChanged: (v) => setState(() => _category = v ?? _category),
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 14),
            CustomDateField(
              label: AppStrings.date,
              selectedDate: _date,
              onDateSelected: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: AppStrings.notes,
              controller: _notesController,
              maxLines: 3,
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }
}
