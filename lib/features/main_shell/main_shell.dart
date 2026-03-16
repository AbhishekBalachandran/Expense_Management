import 'package:expense_manager/core/router/app_routes.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const List<String> _tabRoutes = [
    AppRoutes.home,
    AppRoutes.transactions,
    AppRoutes.profile,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.transactions)) return 1;
    if (location.startsWith(AppRoutes.profile)) return 2;
    return 0; //home
  }

  void ontabTap(BuildContext context, int index) {
    final current = _currentIndex(context);
    if (current == index) return;
    context.go(_tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ontabTap(context, index),
      ),
      floatingActionButton: currentIndex == 0
          ? _AddFab(onTap: () => context.push(AppRoutes.addTransaction))
          : null,
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        height: AppDimensions.bottomNavHeight,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: Colors.white38),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: _NavItem(
                icon: "assets/images/home.png",
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              flex: 1,
              child: _NavItem(
                icon: "assets/images/transactions.png",
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),

            Expanded(
              flex: 1,
              child: _NavItem(
                icon: "assets/images/profile.png",
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: Image.asset(icon, width: 28, height: 28)),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.fabSize,
        height: AppDimensions.fabSize,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.fabGradient,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.primaryText,
          size: 28,
        ),
      ),
    );
  }
}
