import 'package:flutter/material.dart';

/// عمومی ڈراپ ڈاؤن - قسم/کیٹیگری منتخب کرنے کے لیے
class CustomDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? icon;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      ),
      isExpanded: true,
      alignment: AlignmentDirectional.centerEnd,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(item, textAlign: TextAlign.right),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
