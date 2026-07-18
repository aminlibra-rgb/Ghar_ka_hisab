import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مربوط انداز کا کسٹم ٹیکسٹ فیلڈ - پوری ایپ میں استعمال ہوتا ہے
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? icon;
  final bool isNumber;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.icon,
    this.isNumber = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : keyboardType,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : null,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
