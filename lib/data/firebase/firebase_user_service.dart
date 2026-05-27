import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_service.dart';
import '../models/user_model.dart';

class FirebaseUserService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createUserProfile(UserModel user) async {
    await _firestoreService.setData(
      reference: _firestoreService.profileDoc(user.uid),
      data: user.toMap(),
    );
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _firestoreService.setData(
      reference: _firestoreService.profileDoc(user.uid),
      data: user.copyWith(updatedAt: DateTime.now()).toMap(),
    );
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final snapshot = await _firestoreService.profileDoc().get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return UserModel.fromMap(snapshot.data()!);
  }

  Stream<UserModel?> watchCurrentUserProfile() {
    return _firestoreService.profileDoc().snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return UserModel.fromMap(snapshot.data()!);
    });
  }

  Future<void> updateCurrency(String currency) async {
    await _firestoreService.profileDoc().update({
      'currency': currency,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateThemeMode(String themeMode) async {
    await _firestoreService.profileDoc().update({
      'themeMode': themeMode,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateReminderMinutesBefore(int minutes) async {
    await _firestoreService.profileDoc().update({
      'reminderMinutesBefore': minutes,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
