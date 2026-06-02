import 'package:flutter/material.dart';

import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => _repository.currentUser != null;
  String? get currentUserId => _repository.currentUserId;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.register(
        name: name,
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.login(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.sendPasswordResetEmail(email: email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.logout();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  void clearError() {
    _setError(null);
  }
}
