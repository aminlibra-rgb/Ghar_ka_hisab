import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/income_model.dart';
import '../../providers/income_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_dropdown.dart';

class AddIncomeScreen extends StatefulWidget {
  final IncomeModel? existing;
  const AddIncomeScreen({super.key, this.existing});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late String _category;
  late DateTime _date;

  final _categories = [
    AppStrings.incomeCategorySalary,
    AppStrings.incomeCategoryBusiness,
    AppStrings.incomeCategoryRent,
    AppStrings.incomeCategoryOther,
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(text: e != null ? e.amount.toStringAsFixed(0) : '');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _category = e?.category ?? _categories.first;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<IncomeProvider>();
    final model = IncomeModel(
      id: widget.existing?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category,
      date: _date,
      notes: _notesController.text.trim(),
    );
    if (widget.existing == null) {
      await provider.addIncome(model);
    } else {
      await provider.updateIncome(model);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? AppStrings.income : AppStrings.edit)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: AppStrings.title,
              controller: _titleController,
              validator: Validators.requiredText,
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 14),
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
