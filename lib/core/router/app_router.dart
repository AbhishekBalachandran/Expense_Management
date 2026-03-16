import 'package:expense_manager/core/router/app_routes.dart';
import 'package:expense_manager/core/storage/prefs_service.dart';
import 'package:expense_manager/features/add_transaction/add_transaction.dart';
import 'package:expense_manager/features/auth/mobile_login.dart';
import 'package:expense_manager/features/auth/name_screen.dart';
import 'package:expense_manager/features/auth/otp_screen.dart';
import 'package:expense_manager/features/home/home_screen.dart';
import 'package:expense_manager/features/main_shell/main_shell.dart';
import 'package:expense_manager/features/onboarding/onboarding.dart';
import 'package:expense_manager/features/profile_screen/profile_screen.dart';
import 'package:expense_manager/features/splash/splash_screen.dart';
import 'package:expense_manager/features/transactions/transactions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static GoRouter generateRouter(PrefsService prefsService) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => SplashScreen(prefsService: prefsService),
        ),
        GoRoute(
          path: AppRoutes.onBoarding,
          name: 'onboarding',
          builder: (context, state) => OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.mobileLogin,
          name: 'mobileLogin',
          builder: (context, state) => MobileLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          name: 'otp',

          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final mobile = extra['mobile'] as String? ?? '';
            return OtpScreen(phone: mobile);
          },
        ),
        GoRoute(
          path: AppRoutes.nickname,
          name: 'nickname',

          builder: (context, state) {
            return NameScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.addTransaction,
          name: 'addTransaction',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: AddTransaction(),
            transitionDuration: const Duration(milliseconds: 380),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final tween = Tween(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => HomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.transactions,
              name: 'transactions',
              builder: (context, state) => TransactionListScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => ProfileScreen(),
            ),
          ],
        ),
      ],

      errorPageBuilder: (context, state) => MaterialPage(
        child: Scaffold(
          body: Center(
            child: Text(
              'Page not found\n${state.error}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
