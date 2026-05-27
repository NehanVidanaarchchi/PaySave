import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String currency;
  final String themeMode;
  final int reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.currency = 'LKR',
    this.themeMode = 'light',
    this.reminderMinutesBefore = 1440,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.empty() {
    final now = DateTime.now();

    return UserModel(
      uid: '',
      name: '',
      email: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? currency,
    String? themeMode,
    int? reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'currency': currency,
      'themeMode': themeMode,
      'reminderMinutesBefore': reminderMinutesBefore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      currency: map['currency'] ?? 'LKR',
      themeMode: map['themeMode'] ?? 'light',
      reminderMinutesBefore: map['reminderMinutesBefore'] ?? 1440,
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
    );
  }

  static DateTime _dateFromValue(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}