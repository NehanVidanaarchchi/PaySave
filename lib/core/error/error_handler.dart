import 'package:flutter/foundation.dart';

import 'firebase_error_handler.dart';

class ErrorHandler {
  /// Convert any error into a user-friendly message
  static String getMessage(dynamic error) {
    if (error == null) {
      return "Something went wrong. Please try again.";
    }

    // Firebase errors
    final firebaseMessage =
        FirebaseErrorHandler.message(error);

    if (firebaseMessage != null) {
      return firebaseMessage;
    }

    // Network errors
    if (error.toString().contains(
          "SocketException",
        )) {
      return "No internet connection. Please check your network.";
    }


    // Timeout errors
    if (error.toString().contains(
          "TimeoutException",
        )) {
      return "Request timeout. Please try again.";
    }


    // Permission errors
    if (error.toString().contains(
          "permission-denied",
        )) {
      return "You don't have permission to perform this action.";
    }


    // Debug print for developers
    if (kDebugMode) {
      debugPrint(
        "Unhandled Error: $error",
      );
    }


    return "Something went wrong. Please try again.";
  }


  /// Log errors
  static void log(
    dynamic error,
    StackTrace stackTrace,
  ) {

    if (kDebugMode) {

      debugPrint(
        "ERROR: $error",
      );

      debugPrint(
        stackTrace.toString(),
      );

    }

    // Later:
    // Firebase Crashlytics integration here
  }
}