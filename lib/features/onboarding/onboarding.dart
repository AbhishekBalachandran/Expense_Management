import 'package:expense_manager/core/router/app_routes.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingData {
  const OnboardingData({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

const List<OnboardingData> _pages = [
  OnboardingData(
    title: 'Privacy by Default, With Zero Ads or Hidden Tracking',
    subtitle: 'No ads. No trackers. No third-party analytics.',
  ),
  OnboardingData(
    title: 'Insights That Help You Spend Better Without Complexity',
    subtitle: 'See category-wise spending, recent activity.',
  ),
  OnboardingData(
    title: 'Local-First Tracking That Stays Fully On Your Device',
    subtitle: 'Your finances stay on your phone.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool get _isLastPage => _currentPage == _pages.length - 1;
  bool get _isFirstPage => _currentPage == 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeIn,
    );
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _onSkip() => context.go(AppRoutes.mobileLogin);

  void _onStart() => context.go(AppRoutes.mobileLogin);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/on_boarding_bg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // dark overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: screenHeight * 0.62,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.8),
                    AppColors.background.withValues(alpha: 0.95),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _pages[index],
                currentPage: _currentPage,
                totalPages: _pages.length,
              );
            },
          ),

          if (!_isLastPage)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: GestureDetector(
                onTap: _onSkip,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'SKIP',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                  ),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomControls(
              isFirstPage: _isFirstPage,
              isLastPage: _isLastPage,
              onBack: _onBack,
              onNext: _onNext,
              onStart: _onStart,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.data,
    required this.currentPage,
    required this.totalPages,
  });

  final OnboardingData data;
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 24,
          right: 24,
          bottom: 148,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PageIndicator(currentPage: currentPage, totalPages: totalPages),
              const SizedBox(height: 26),
              Text(
                data.title,
                style: AppTextStyles.headingLarge.copyWith(height: 1.25),
              ),
              const SizedBox(height: 10),
              Text(
                data.subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BottomControls extends StatelessWidget {
  const BottomControls({
    super.key,
    required this.isFirstPage,
    required this.isLastPage,
    required this.onBack,
    required this.onNext,
    required this.onStart,
  });

  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (!isFirstPage) ...[
                BackButton(onTap: onBack),
                const SizedBox(width: 12),
              ],

              Expanded(
                child: isLastPage
                    ? PrimaryButton(label: 'Get Started', onTap: onStart)
                    : PrimaryButton(label: 'Next', onTap: onNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPages, (index) {
        return Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            height: 3,
            decoration: BoxDecoration(
              color: index <= currentPage ? Colors.white : Colors.white24,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
        );
      }),
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryText, width: 1.2),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}
