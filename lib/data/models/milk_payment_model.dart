/// گاہک کی طرف سے دودھ کے بل کی ادائیگی کا ریکارڈ
class MilkPaymentModel {
  final int? id;
  final int customerId;
  final DateTime date;
  final double amount;
  final String notes;

  MilkPaymentModel({
    this.id,
    required this.customerId,
    required this.date,
    required this.amount,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'date': date.toIso8601String().substring(0, 10),
      'amount': amount,
      'notes': notes,
    };
  }

  factory MilkPaymentModel.fromMap(Map<String, dynamic> map) {
    return MilkPaymentModel(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }
}
