import 'package:expense_manager/core/router/app_routes.dart';
import 'package:expense_manager/core/storage/prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  final PrefsService prefsService;
  const SplashScreen({super.key, required this.prefsService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> animationFade;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animationFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );
    _controller.forward();
    navigate();
  }

  Future<void> navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final isLoggedIn = widget.prefsService.hasToken;
    if (isLoggedIn) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onBoarding);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: animationFade,
          child: Image.asset(
            "assets/logo/Logo.png",
            width: 130,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
