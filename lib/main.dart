import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/error/app_error_screen.dart';
import 'core/error/error_handler.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/installment_provider.dart';
import 'providers/money_record_provider.dart';
import 'providers/monthly_plan_provider.dart';
import 'providers/saving_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();


  // Global Flutter UI error handler
  // Replace Flutter red error screen
  ErrorWidget.builder =
      (FlutterErrorDetails details) {

    return AppErrorScreen(
      message:
          "Something went wrong.\nPlease restart the app.",
    );

  };


  // Firebase initialization
  try {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(true);

    FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  } catch (e, stackTrace) {

    ErrorHandler.log(
      e,
      stackTrace,
    );

    runApp(
      const AppErrorScreen(
        message:
            "Firebase connection failed.\nPlease try again later.",
      ),
    );

    return;
  }

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );

    return true;
  };



  // Notification initialization
  try {

    await NotificationService.instance.init();

  } catch (e, stackTrace) {

    ErrorHandler.log(
      e,
      stackTrace,
    );

  }



  // Load saved theme
  final themeProvider = ThemeProvider();

  try {

    await themeProvider.loadTheme();

  } catch (e, stackTrace) {

    ErrorHandler.log(
      e,
      stackTrace,
    );

  }



  runApp(

    MultiProvider(

      providers: [


        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),


        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),


        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),


        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),


        ChangeNotifierProvider<MonthlyPlanProvider>(
          create: (_) => MonthlyPlanProvider(),
        ),


        ChangeNotifierProvider<BillProvider>(
          create: (_) => BillProvider(),
        ),


        ChangeNotifierProvider<InstallmentProvider>(
          create: (_) => InstallmentProvider(),
        ),


        ChangeNotifierProvider<SavingProvider>(
          create: (_) => SavingProvider(),
        ),


        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => ExpenseProvider(),
        ),


        ChangeNotifierProvider<MoneyRecordProvider>(
          create: (_) => MoneyRecordProvider(),
        ),

      ],


      child: const PaySaveApp(),

    ),

  );

}