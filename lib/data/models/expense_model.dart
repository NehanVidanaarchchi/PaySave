import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  static const String typeExpense = 'expense';
  static const String typeIncome = 'income';

  final String id;
  final String userId;

  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String note;

  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIncome {
    return type == typeIncome;
  }

  bool get isExpense {
    return type == typeExpense;
  }

  factory ExpenseModel.empty({required String userId}) {
    final now = DateTime.now();

    return ExpenseModel(
      id: '',
      userId: userId,
      title: '',
      amount: 0,
      type: typeExpense,
      category: 'Other',
      date: now,
      note: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: _doubleFromValue(map['amount']),
      type: map['type'] ?? typeExpense,
      category: map['category'] ?? 'Other',
      date: _dateFromValue(map['date']),
      note: map['note'] ?? '',
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

  static DateTime _dateFromValue(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
