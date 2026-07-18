/// دکان کرایہ کے ماہانہ ریکارڈ کا ماڈل
class RentModel {
  final int? id;
  final String monthKey; // yyyy-MM
  final double monthlyRent;
  final double paidAmount;
  final DateTime dueDate;
  final String notes;

  RentModel({
    this.id,
    required this.monthKey,
    required this.monthlyRent,
    this.paidAmount = 0,
    required this.dueDate,
    this.notes = '',
  });

  double get remainingAmount => (monthlyRent - paidAmount).clamp(0, double.infinity);
  bool get isPaid => paidAmount >= monthlyRent;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'month_key': monthKey,
      'monthly_rent': monthlyRent,
      'paid_amount': paidAmount,
      'due_date': dueDate.toIso8601String().substring(0, 10),
      'notes': notes,
    };
  }

  factory RentModel.fromMap(Map<String, dynamic> map) {
    return RentModel(
      id: map['id'] as int?,
      monthKey: map['month_key'] as String,
      monthlyRent: (map['monthly_rent'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0,
      dueDate: DateTime.parse(map['due_date'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }

  RentModel copyWith({
    int? id,
    String? monthKey,
    double? monthlyRent,
    double? paidAmount,
    DateTime? dueDate,
    String? notes,
  }) {
    return RentModel(
      id: id ?? this.id,
      monthKey: monthKey ?? this.monthKey,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }
}

/// کرایہ کی جزوی ادائیگیوں کا ریکارڈ
class RentPaymentModel {
  final int? id;
  final int rentId;
  final double amount;
  final DateTime date;
  final String notes;

  RentPaymentModel({
    this.id,
    required this.rentId,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'rent_id': rentId,
      'amount': amount,
      'date': date.toIso8601String().substring(0, 10),
      'notes': notes,
    };
  }

  factory RentPaymentModel.fromMap(Map<String, dynamic> map) {
    return RentPaymentModel(
      id: map['id'] as int?,
      rentId: map['rent_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }
}
