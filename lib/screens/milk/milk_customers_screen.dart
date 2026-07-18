import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/customer_model.dart';
import '../../providers/milk_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import 'milk_customer_detail_screen.dart';

class MilkCustomersScreen extends StatefulWidget {
  const MilkCustomersScreen({super.key});

  @override
  State<MilkCustomersScreen> createState() => _MilkCustomersScreenState();
}

class _MilkCustomersScreenState extends State<MilkCustomersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilkProvider>().loadCustomers();
    });
  }

  void _showPriceDialog(MilkProvider provider) {
    final controller = TextEditingController(text: provider.milkPrice.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.milkPricePerLiter, textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(prefixText: 'Rs '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text) ?? provider.milkPrice;
              provider.setMilkPrice(price);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(MilkProvider provider, {CustomerModel? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? AppStrings.addCustomer : AppStrings.edit, textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: AppStrings.customerName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: AppStrings.phoneNumber),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              if (existing == null) {
                await provider.addCustomer(nameController.text.trim(), phoneController.text.trim());
              } else {
                await provider.updateCustomer(
                  existing.copyWith(name: nameController.text.trim(), phone: phoneController.text.trim()),
                );
              }
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
    final provider = context.watch<MilkProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.milk),
        actions: [
          IconButton(
            icon: const Icon(Icons.price_change_outlined),
            tooltip: AppStrings.milkPricePerLiter,
            onPressed: () => _showPriceDialog(provider),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.milkGradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.local_drink_rounded, color: Colors.white, size: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${CurrencyFormatter.formatDecimal(provider.milkPrice)} / لیٹر',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(AppStrings.milkPricePerLiter, style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.customers.isEmpty
                    ? const EmptyState(message: 'کوئی گاہک شامل نہیں', icon: Icons.people_outline)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: provider.customers.length,
                        itemBuilder: (context, index) {
                          final customer = provider.customers[index];
                          return Card(
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => MilkCustomerDetailScreen(customer: customer)),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.milkGradient.first.withOpacity(0.15),
                                child: Text(
                                  customer.name.isNotEmpty ? customer.name[0] : '?',
                                  style: TextStyle(color: AppColors.milkGradient.first, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(customer.name, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(customer.phone.isEmpty ? '—' : customer.phone, textAlign: TextAlign.right),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _showAddCustomerDialog(provider, existing: customer);
                                  } else if (value == 'delete') {
                                    final confirm = await showConfirmDialog(context);
                                    if (confirm && customer.id != null) {
                                      await provider.deleteCustomer(customer.id!);
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'edit', child: Text(AppStrings.edit)),
                                  PopupMenuItem(value: 'delete', child: Text(AppStrings.delete)),
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
        onPressed: () => _showAddCustomerDialog(provider),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }
}
