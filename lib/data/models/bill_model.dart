import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  static const String repeatOneTime = 'one_time';
  static const String repeatWeekly = 'weekly';
  static const String repeatMonthly = 'monthly';
  static const String repeatYearly = 'yearly';

  final String id;
  final String userId;

  final String billName;
  final String category;
  final double amount;

  final DateTime dueDate;
  final DateTime reminderDateTime;

  final String repeatType;
  final bool isPaid;
  final String note;

  final DateTime createdAt;
  final DateTime updatedAt;

  BillModel({
    required this.id,
    required this.userId,
    required this.billName,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.reminderDateTime,
    required this.repeatType,
    required this.isPaid,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return !isPaid && due.isBefore(today);
  }

  bool get isDueToday {
    final now = DateTime.now();

    return now.year == dueDate.year &&
        now.month == dueDate.month &&
        now.day == dueDate.day;
  }

  int get notificationId {
    return id.hashCode.abs();
  }

  factory BillModel.empty({required String userId}) {
    final now = DateTime.now();

    return BillModel(
      id: '',
      userId: userId,
      billName: '',
      category: 'Other',
      amount: 0,
      dueDate: now,
      reminderDateTime: now,
      repeatType: repeatMonthly,
      isPaid: false,
      note: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  BillModel copyWith({
    String? id,
    String? userId,
    String? billName,
    String? category,
    double? amount,
    DateTime? dueDate,
    DateTime? reminderDateTime,
    String? repeatType,
    bool? isPaid,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      billName: billName ?? this.billName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      repeatType: repeatType ?? this.repeatType,
      isPaid: isPaid ?? this.isPaid,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  BillModel markAsPaid() {
    return copyWith(isPaid: true, updatedAt: DateTime.now());
  }

  BillModel markAsUnpaid() {
    return copyWith(isPaid: false, updatedAt: DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'billName': billName,
      'category': category,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'reminderDateTime': Timestamp.fromDate(reminderDateTime),
      'repeatType': repeatType,
      'isPaid': isPaid,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      billName: map['billName'] ?? '',
      category: map['category'] ?? 'Other',
      amount: _doubleFromValue(map['amount']),
      dueDate: _dateFromValue(map['dueDate']),
      reminderDateTime: _dateFromValue(map['reminderDateTime']),
      repeatType: map['repeatType'] ?? repeatMonthly,
      isPaid: map['isPaid'] ?? false,
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
