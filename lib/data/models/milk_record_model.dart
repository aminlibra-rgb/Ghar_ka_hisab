/// دودھ کا یومیہ ریکارڈ - ہر گاہک کے لیے روزانہ مقدار
class MilkRecordModel {
  final int? id;
  final int customerId;
  final DateTime date;
  final double quantityLiters;
  final double pricePerLiter;
  final String notes;

  MilkRecordModel({
    this.id,
    required this.customerId,
    required this.date,
    required this.quantityLiters,
    required this.pricePerLiter,
    this.notes = '',
  });

  double get totalAmount => quantityLiters * pricePerLiter;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'date': date.toIso8601String().substring(0, 10),
      'quantity_liters': quantityLiters,
      'price_per_liter': pricePerLiter,
      'notes': notes,
    };
  }

  factory MilkRecordModel.fromMap(Map<String, dynamic> map) {
    return MilkRecordModel(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      date: DateTime.parse(map['date'] as String),
      quantityLiters: (map['quantity_liters'] as num).toDouble(),
      pricePerLiter: (map['price_per_liter'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }

  MilkRecordModel copyWith({
    int? id,
    int? customerId,
    DateTime? date,
    double? quantityLiters,
    double? pricePerLiter,
    String? notes,
  }) {
    return MilkRecordModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      quantityLiters: quantityLiters ?? this.quantityLiters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      notes: notes ?? this.notes,
    );
  }
}
