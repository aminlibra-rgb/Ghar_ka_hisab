import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

import 'providers/theme_provider.dart';
import 'providers/milk_provider.dart';
import 'providers/income_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/borrow_lend_provider.dart';
import 'providers/rent_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/auth_provider.dart';

import 'services/notification_service.dart';

import 'screens/auth/lock_screen.dart';
import 'screens/dashboard/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const GharKaHisabApp());
}

class GharKaHisabApp extends StatelessWidget {
  const GharKaHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MilkProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => BorrowLendProvider()),
        ChangeNotifierProvider(create: (_) => RentProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // اردو کے لیے دائیں سے بائیں (RTL) سمت
            locale: const Locale('ur', 'PK'),
            supportedLocales: const [Locale('ur', 'PK'), Locale('en', 'US')],
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AppLockGate(),
          );
        },
      ),
    );
  }
}

/// ایپ شروع ہوتے وقت طے کرتا ہے کہ لاک اسکرین دکھانی ہے یا سیدھا ڈیش بورڈ
class AppLockGate extends StatelessWidget {
  const AppLockGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isUnlocked) {
          return const LockScreen();
        }
        return const HomeShell();
      },
    );
  }
}
