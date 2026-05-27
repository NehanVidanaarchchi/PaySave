import 'package:cloud_firestore/cloud_firestore.dart';

class SavingGoalModel {
  final String id;
  final String userId;

  final String goalName;
  final double targetAmount;
  final double savedAmount;
  final double monthlyTarget;
  final DateTime targetDate;
  final String note;

  final DateTime createdAt;
  final DateTime updatedAt;

  SavingGoalModel({
    required this.id,
    required this.userId,
    required this.goalName,
    required this.targetAmount,
    required this.savedAmount,
    required this.monthlyTarget,
    required this.targetDate,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0, 1);
  }

  double get remainingAmount {
    final remaining = targetAmount - savedAmount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isCompleted {
    return savedAmount >= targetAmount;
  }

  int get daysLeft {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  factory SavingGoalModel.empty({required String userId}) {
    final now = DateTime.now();

    return SavingGoalModel(
      id: '',
      userId: userId,
      goalName: '',
      targetAmount: 0,
      savedAmount: 0,
      monthlyTarget: 0,
      targetDate: now,
      note: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  SavingGoalModel copyWith({
    String? id,
    String? userId,
    String? goalName,
    double? targetAmount,
    double? savedAmount,
    double? monthlyTarget,
    DateTime? targetDate,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  SavingGoalModel addSaving(double amount) {
    return copyWith(
      savedAmount: savedAmount + amount,
      updatedAt: DateTime.now(),
    );
  }

  SavingGoalModel removeSaving(double amount) {
    final newAmount = savedAmount - amount;

    return copyWith(
      savedAmount: newAmount < 0 ? 0 : newAmount,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'monthlyTarget': monthlyTarget,
      'targetDate': Timestamp.fromDate(targetDate),
      'note': note,
      'progress': progress,
      'remainingAmount': remainingAmount,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SavingGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingGoalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      goalName: map['goalName'] ?? '',
      targetAmount: _doubleFromValue(map['targetAmount']),
      savedAmount: _doubleFromValue(map['savedAmount']),
      monthlyTarget: _doubleFromValue(map['monthlyTarget']),
      targetDate: _dateFromValue(map['targetDate']),
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
