import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyPlanModel {
  final String id;
  final String userId;
  final String monthKey;

  final double monthlyIncome;
  final double rentAmount;
  final double billsBudget;
  final double savingTarget;
  final double foodBudget;
  final double transportBudget;
  final double otherBudget;

  final DateTime createdAt;
  final DateTime updatedAt;

  MonthlyPlanModel({
    required this.id,
    required this.userId,
    required this.monthKey,
    required this.monthlyIncome,
    required this.rentAmount,
    required this.billsBudget,
    required this.savingTarget,
    required this.foodBudget,
    required this.transportBudget,
    required this.otherBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalPlanned {
    return rentAmount +
        billsBudget +
        savingTarget +
        foodBudget +
        transportBudget +
        otherBudget;
  }

  double get remainingBalance {
    return monthlyIncome - totalPlanned;
  }

  double get fixedCosts {
    return rentAmount + billsBudget;
  }

  double get spendingBudget {
    return foodBudget + transportBudget + otherBudget;
  }

  bool get isOverBudget {
    return remainingBalance < 0;
  }

  double get dailySafeSpending {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = lastDay - now.day + 1;

    if (daysLeft <= 0) return 0;
    if (remainingBalance <= 0) return 0;

    return remainingBalance / daysLeft;
  }

  factory MonthlyPlanModel.empty({
    required String userId,
    required String monthKey,
  }) {
    final now = DateTime.now();

    return MonthlyPlanModel(
      id: '',
      userId: userId,
      monthKey: monthKey,
      monthlyIncome: 0,
      rentAmount: 0,
      billsBudget: 0,
      savingTarget: 0,
      foodBudget: 0,
      transportBudget: 0,
      otherBudget: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  MonthlyPlanModel copyWith({
    String? id,
    String? userId,
    String? monthKey,
    double? monthlyIncome,
    double? rentAmount,
    double? billsBudget,
    double? savingTarget,
    double? foodBudget,
    double? transportBudget,
    double? otherBudget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthKey: monthKey ?? this.monthKey,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      rentAmount: rentAmount ?? this.rentAmount,
      billsBudget: billsBudget ?? this.billsBudget,
      savingTarget: savingTarget ?? this.savingTarget,
      foodBudget: foodBudget ?? this.foodBudget,
      transportBudget: transportBudget ?? this.transportBudget,
      otherBudget: otherBudget ?? this.otherBudget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthKey': monthKey,
      'monthlyIncome': monthlyIncome,
      'rentAmount': rentAmount,
      'billsBudget': billsBudget,
      'savingTarget': savingTarget,
      'foodBudget': foodBudget,
      'transportBudget': transportBudget,
      'otherBudget': otherBudget,
      'totalPlanned': totalPlanned,
      'remainingBalance': remainingBalance,
      'fixedCosts': fixedCosts,
      'spendingBudget': spendingBudget,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MonthlyPlanModel.fromMap(Map<String, dynamic> map) {
    return MonthlyPlanModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      monthKey: map['monthKey'] ?? '',
      monthlyIncome: _doubleFromValue(map['monthlyIncome']),
      rentAmount: _doubleFromValue(map['rentAmount']),
      billsBudget: _doubleFromValue(map['billsBudget']),
      savingTarget: _doubleFromValue(map['savingTarget']),
      foodBudget: _doubleFromValue(map['foodBudget']),
      transportBudget: _doubleFromValue(map['transportBudget']),
      otherBudget: _doubleFromValue(map['otherBudget']),
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