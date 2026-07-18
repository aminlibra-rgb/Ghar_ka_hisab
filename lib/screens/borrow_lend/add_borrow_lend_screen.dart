import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/borrow_lend_model.dart';
import '../../providers/borrow_lend_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';

class AddBorrowLendScreen extends StatefulWidget {
  final bool isGiven;
  const AddBorrowLendScreen({super.key, required this.isGiven});

  @override
  State<AddBorrowLendScreen> createState() => _AddBorrowLendScreenState();
}

class _AddBorrowLendScreenState extends State<AddBorrowLendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<BorrowLendProvider>();
    final model = BorrowLendModel(
      personName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: _date,
      notes: _notesController.text.trim(),
      type: widget.isGiven ? AppConstants.typeGiven : AppConstants.typeReceived,
    );
    await provider.addItem(model);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isGiven ? AppStrings.moneyGiven : AppStrings.moneyReceived)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: AppStrings.personName,
              controller: _nameController,
              validator: Validators.requiredText,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: AppStrings.phoneNumber,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
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
            ElevatedButton(onPressed: _save, child: const Text(AppStrings.save)),
          ],
        ),
      ),
    );
  }
}
