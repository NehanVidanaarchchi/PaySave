import 'package:cloud_firestore/cloud_firestore.dart';

class InstallmentPaymentModel {
  final String id;
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final DateTime reminderDateTime;
  final bool isPaid;

  InstallmentPaymentModel({
    required this.id,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    required this.reminderDateTime,
    required this.isPaid,
  });

  int get notificationId {
    return id.hashCode.abs();
  }

  InstallmentPaymentModel copyWith({
    String? id,
    int? installmentNumber,
    double? amount,
    DateTime? dueDate,
    DateTime? reminderDateTime,
    bool? isPaid,
  }) {
    return InstallmentPaymentModel(
      id: id ?? this.id,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'installmentNumber': installmentNumber,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'reminderDateTime': Timestamp.fromDate(reminderDateTime),
      'isPaid': isPaid,
    };
  }

  factory InstallmentPaymentModel.fromMap(Map<String, dynamic> map) {
    return InstallmentPaymentModel(
      id: map['id'] ?? '',
      installmentNumber: map['installmentNumber'] ?? 1,
      amount: _doubleFromValue(map['amount']),
      dueDate: _dateFromValue(map['dueDate']),
      reminderDateTime: _dateFromValue(map['reminderDateTime']),
      isPaid: map['isPaid'] ?? false,
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

class InstallmentModel {
  final String id;
  final String userId;

  final String purchaseName;
  final String provider;
  final double totalAmount;
  final int installmentCount;
  final double installmentAmount;

  final DateTime firstPaymentDate;
  final DateTime reminderTime;
  final String note;

  final List<InstallmentPaymentModel> payments;

  final DateTime createdAt;
  final DateTime updatedAt;

  InstallmentModel({
    required this.id,
    required this.userId,
    required this.purchaseName,
    required this.provider,
    required this.totalAmount,
    required this.installmentCount,
    required this.installmentAmount,
    required this.firstPaymentDate,
    required this.reminderTime,
    required this.note,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });

  int get paidInstallments {
    return payments.where((payment) => payment.isPaid).length;
  }

  int get unpaidInstallments {
    return payments.where((payment) => !payment.isPaid).length;
  }

  double get paidAmount {
    return payments
        .where((payment) => payment.isPaid)
        .fold<double>(0, (total, payment) => total + payment.amount);
  }

  double get remainingAmount {
    return totalAmount - paidAmount;
  }

  double get progress {
    if (installmentCount <= 0) return 0;
    return paidInstallments / installmentCount;
  }

  InstallmentPaymentModel? get nextPayment {
    final unpaid = payments.where((payment) => !payment.isPaid).toList();

    if (unpaid.isEmpty) return null;

    unpaid.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return unpaid.first;
  }

  bool get isCompleted {
    return paidInstallments >= installmentCount;
  }

  factory InstallmentModel.empty({required String userId}) {
    final now = DateTime.now();

    return InstallmentModel(
      id: '',
      userId: userId,
      purchaseName: '',
      provider: 'Koko',
      totalAmount: 0,
      installmentCount: 3,
      installmentAmount: 0,
      firstPaymentDate: now,
      reminderTime: now,
      note: '',
      payments: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory InstallmentModel.createWithPayments({
    required String id,
    required String userId,
    required String purchaseName,
    required String provider,
    required double totalAmount,
    required int installmentCount,
    required DateTime firstPaymentDate,
    required DateTime reminderTime,
    String note = '',
  }) {
    final now = DateTime.now();
    final safeCount = installmentCount <= 0 ? 1 : installmentCount;
    final installmentAmount = totalAmount / safeCount;

    final payments = List.generate(safeCount, (index) {
      final dueDate = DateTime(
        firstPaymentDate.year,
        firstPaymentDate.month + index,
        firstPaymentDate.day,
      );

      final reminderDateTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      return InstallmentPaymentModel(
        id: '${id}_payment_${index + 1}',
        installmentNumber: index + 1,
        amount: installmentAmount,
        dueDate: dueDate,
        reminderDateTime: reminderDateTime,
        isPaid: false,
      );
    });

    return InstallmentModel(
      id: id,
      userId: userId,
      purchaseName: purchaseName,
      provider: provider,
      totalAmount: totalAmount,
      installmentCount: safeCount,
      installmentAmount: installmentAmount,
      firstPaymentDate: firstPaymentDate,
      reminderTime: reminderTime,
      note: note,
      payments: payments,
      createdAt: now,
      updatedAt: now,
    );
  }

  InstallmentModel copyWith({
    String? id,
    String? userId,
    String? purchaseName,
    String? provider,
    double? totalAmount,
    int? installmentCount,
    double? installmentAmount,
    DateTime? firstPaymentDate,
    DateTime? reminderTime,
    String? note,
    List<InstallmentPaymentModel>? payments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstallmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      purchaseName: purchaseName ?? this.purchaseName,
      provider: provider ?? this.provider,
      totalAmount: totalAmount ?? this.totalAmount,
      installmentCount: installmentCount ?? this.installmentCount,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
      reminderTime: reminderTime ?? this.reminderTime,
      note: note ?? this.note,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  InstallmentModel markPaymentPaid(String paymentId) {
    final updatedPayments = payments.map((payment) {
      if (payment.id == paymentId) {
        return payment.copyWith(isPaid: true);
      }
      return payment;
    }).toList();

    return copyWith(payments: updatedPayments, updatedAt: DateTime.now());
  }

  InstallmentModel markPaymentUnpaid(String paymentId) {
    final updatedPayments = payments.map((payment) {
      if (payment.id == paymentId) {
        return payment.copyWith(isPaid: false);
      }
      return payment;
    }).toList();

    return copyWith(payments: updatedPayments, updatedAt: DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'purchaseName': purchaseName,
      'provider': provider,
      'totalAmount': totalAmount,
      'installmentCount': installmentCount,
      'installmentAmount': installmentAmount,
      'firstPaymentDate': Timestamp.fromDate(firstPaymentDate),
      'reminderTime': Timestamp.fromDate(reminderTime),
      'note': note,
      'payments': payments.map((payment) => payment.toMap()).toList(),
      'paidInstallments': paidInstallments,
      'remainingAmount': remainingAmount,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory InstallmentModel.fromMap(Map<String, dynamic> map) {
    final rawPayments = map['payments'];

    final paymentList = rawPayments is List
        ? rawPayments
              .map(
                (item) => InstallmentPaymentModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <InstallmentPaymentModel>[];

    return InstallmentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      purchaseName: map['purchaseName'] ?? '',
      provider: map['provider'] ?? '',
      totalAmount: _doubleFromValue(map['totalAmount']),
      installmentCount: map['installmentCount'] ?? 0,
      installmentAmount: _doubleFromValue(map['installmentAmount']),
      firstPaymentDate: _dateFromValue(map['firstPaymentDate']),
      reminderTime: _dateFromValue(map['reminderTime']),
      note: map['note'] ?? '',
      payments: paymentList,
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
