import '../../core/constants/app_constants.dart';

/// یوٹیلیٹی بلوں کا ماڈل (بجلی، گیس، پانی، انٹرنیٹ وغیرہ)
class BillModel {
  final int? id;
  final String billName;
  final String billType; // Electricity, Gas, Water, Internet, Mobile, Other
  final double totalAmount;
  final double paidAmount;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final String status; // paid / pending
  final String notes;

  BillModel({
    this.id,
    required this.billName,
    required this.billType,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.dueDate,
    this.paymentDate,
    String? status,
    this.notes = '',
  }) : status = status ??
            (paidAmount >= totalAmount ? AppConstants.statusPaid : AppConstants.statusPending);

  double get remainingAmount => (totalAmount - paidAmount).clamp(0, double.infinity);
  bool get isPaid => status == AppConstants.statusPaid;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bill_name': billName,
      'bill_type': billType,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'due_date': dueDate.toIso8601String().substring(0, 10),
      'payment_date': paymentDate?.toIso8601String().substring(0, 10),
      'status': status,
      'notes': notes,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      billName: map['bill_name'] as String,
      billType: map['bill_type'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0,
      dueDate: DateTime.parse(map['due_date'] as String),
      paymentDate: map['payment_date'] != null
          ? DateTime.tryParse(map['payment_date'] as String)
          : null,
      status: map['status'] as String? ?? AppConstants.statusPending,
      notes: map['notes'] as String? ?? '',
    );
  }

  BillModel copyWith({
    int? id,
    String? billName,
    String? billType,
    double? totalAmount,
    double? paidAmount,
    DateTime? dueDate,
    DateTime? paymentDate,
    String? status,
    String? notes,
  }) {
    return BillModel(
      id: id ?? this.id,
      billName: billName ?? this.billName,
      billType: billType ?? this.billType,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status,
      notes: notes ?? this.notes,
    );
  }
}
