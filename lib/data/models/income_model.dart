/// آمدنی کا ماڈل
class IncomeModel {
  final int? id;
  final String title;
  final double amount;
  final String category; // Salary, Business, Rent, Other
  final DateTime date;
  final String notes;

  IncomeModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String().substring(0, 10),
      'notes': notes,
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }

  IncomeModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
