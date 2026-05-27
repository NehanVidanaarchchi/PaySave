import 'package:flutter/material.dart';

import '../data/firebase/firebase_user_service.dart';
import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseUserService _userService = FirebaseUserService();

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _setError(null);

      user = await _userService.getCurrentUserProfile();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  Stream<UserModel?> watchUserProfile() {
    return _userService.watchCurrentUserProfile();
  }

  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      _setLoading(true);
      _setError(null);

      await _userService.updateUserProfile(updatedUser);
      user = updatedUser;

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateCurrency(String currency) async {
    try {
      await _userService.updateCurrency(currency);

      if (user != null) {
        user = user!.copyWith(currency: currency, updatedAt: DateTime.now());
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateThemeMode(String themeMode) async {
    try {
      await _userService.updateThemeMode(themeMode);

      if (user != null) {
        user = user!.copyWith(themeMode: themeMode, updatedAt: DateTime.now());
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateReminderMinutesBefore(int minutes) async {
    try {
      await _userService.updateReminderMinutesBefore(minutes);

      if (user != null) {
        user = user!.copyWith(
          reminderMinutesBefore: minutes,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void clearUser() {
    user = null;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
