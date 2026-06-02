import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firebase_auth_service.dart';
import '../firebase/firebase_user_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseUserService _userService = FirebaseUserService();

  User? get currentUser => _authService.currentUser;

  String? get currentUserId => _authService.currentUserId;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.register(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Failed to create user');
    }

    await _authService.updateDisplayName(name);

    final now = DateTime.now();

    final user = UserModel(
      uid: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      photoUrl: firebaseUser.photoURL,
      createdAt: now,
      updatedAt: now,
    );

    await _userService.createUserProfile(user);

    return user;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _authService.login(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _authService.sendPasswordResetEmail(
      email: email,
    );
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
