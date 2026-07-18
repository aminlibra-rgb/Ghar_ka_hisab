import 'package:flutter/material.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

/// آمدنی/اخراجات وغیرہ کی فہرست میں استعمال ہونے والا مشترکہ ٹائل
class TransactionTile extends StatelessWidget {
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final Color amountColor;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.amountColor,
    required this.icon,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.15),
          child: Icon(icon, color: amountColor, size: 20),
        ),
        title: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '$category  •  ${DateFormatter.display(date)}',
          textAlign: TextAlign.right,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
