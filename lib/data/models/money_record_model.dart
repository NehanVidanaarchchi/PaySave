import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyRecordModel {
  static const String typeSalary = 'salary';
  static const String typeIncome = 'income';
  static const String typeBill = 'bill';
  static const String typeExpense = 'expense';
  static const String typeSaving = 'saving';
  static const String typeInstallment = 'installment';

  final String id;
  final String userId;

  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String note;

  final bool isPaid;

  final String? installmentGroupId;
  final int? installmentIndex;
  final int? installmentMonths;

  final DateTime createdAt;
  final DateTime updatedAt;

  const MoneyRecordModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
    required this.isPaid,
    this.installmentGroupId,
    this.installmentIndex,
    this.installmentMonths,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIncome => type == typeSalary || type == typeIncome;
  bool get isBill => type == typeBill;
  bool get isExpense => type == typeExpense;
  bool get isSaving => type == typeSaving;
  bool get isInstallment => type == typeInstallment;

  bool get isOutgoing {
    return isBill || isExpense || isSaving || isInstallment;
  }

  String get displayType {
    switch (type) {
      case typeSalary:
        return 'Salary';
      case typeIncome:
        return 'Income';
      case typeBill:
        return 'Bill';
      case typeExpense:
        return 'Expense';
      case typeSaving:
        return 'Saving';
      case typeInstallment:
        return 'Installment';
      default:
        return 'Record';
    }
  }

  MoneyRecordModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
    bool? isPaid,
    String? installmentGroupId,
    int? installmentIndex,
    int? installmentMonths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoneyRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isPaid: isPaid ?? this.isPaid,
      installmentGroupId: installmentGroupId ?? this.installmentGroupId,
      installmentIndex: installmentIndex ?? this.installmentIndex,
      installmentMonths: installmentMonths ?? this.installmentMonths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      'isPaid': isPaid,
      'installmentGroupId': installmentGroupId,
      'installmentIndex': installmentIndex,
      'installmentMonths': installmentMonths,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MoneyRecordModel.fromMap(Map<String, dynamic> map) {
    return MoneyRecordModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: _doubleFromValue(map['amount']),
      type: map['type'] ?? typeExpense,
      category: map['category'] ?? 'Other',
      date: _dateFromValue(map['date']),
      note: map['note'] ?? '',
      isPaid: map['isPaid'] ?? false,
      installmentGroupId: map['installmentGroupId'],
      installmentIndex: _intFromValue(map['installmentIndex']),
      installmentMonths: _intFromValue(map['installmentMonths']),
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
    );
  }

  static double _doubleFromValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int? _intFromValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime _dateFromValue(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}