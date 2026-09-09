import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/no_internet_screen.dart';
import '../providers/connectivity_provider.dart';
import '../providers/theme_provider.dart';
import 'app_routes.dart';
import 'app_theme.dart';

class PaySaveApp extends StatelessWidget {
  const PaySaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        if (!connectivity.hasInternet) {
          return NoInternetScreen(
            onRetry: () {
              connectivity.checkNow();
            },
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PaySave',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}