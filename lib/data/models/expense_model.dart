/// اخراجات کا ماڈل
class ExpenseModel {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final String notes;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String().substring(0, 10),
      'notes': notes,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }

  ExpenseModel copyWith({
    int? id,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
