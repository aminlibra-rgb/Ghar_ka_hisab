/// ادھار لین دین کا ماڈل - "دیا" یا "لیا" دونوں کے لیے
/// type: 'given' = میں نے کسی کو رقم دی (مجھے واپس ملنی ہے)
/// type: 'received' = میں نے کسی سے رقم لی (مجھے واپس دینی ہے)
class BorrowLendModel {
  final int? id;
  final String personName;
  final String phoneNumber;
  final double amount;
  final DateTime date;
  final String notes;
  final String type;

  BorrowLendModel({
    this.id,
    required this.personName,
    this.phoneNumber = '',
    required this.amount,
    required this.date,
    this.notes = '',
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'person_name': personName,
      'phone_number': phoneNumber,
      'amount': amount,
      'date': date.toIso8601String().substring(0, 10),
      'notes': notes,
      'type': type,
    };
  }

  factory BorrowLendModel.fromMap(Map<String, dynamic> map) {
    return BorrowLendModel(
      id: map['id'] as int?,
      personName: map['person_name'] as String,
      phoneNumber: map['phone_number'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
      type: map['type'] as String,
    );
  }

  BorrowLendModel copyWith({
    int? id,
    String? personName,
    String? phoneNumber,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return BorrowLendModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      type: type,
    );
  }
}

/// ادھار کے خلاف جزوی ادائیگی کا ریکارڈ
class BorrowLendPaymentModel {
  final int? id;
  final int borrowLendId;
  final double amount;
  final DateTime date;
  final String notes;

  BorrowLendPaymentModel({
    this.id,
    required this.borrowLendId,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'borrow_lend_id': borrowLendId,
      'amount': amount,
      'date': date.toIso8601String().substring(0, 10),
      'notes': notes,
    };
  }

  factory BorrowLendPaymentModel.fromMap(Map<String, dynamic> map) {
    return BorrowLendPaymentModel(
      id: map['id'] as int?,
      borrowLendId: map['borrow_lend_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }
}
