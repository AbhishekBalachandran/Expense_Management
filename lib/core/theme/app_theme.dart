import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // primary colors
  static const Color primary = Color(0xFF312ECB);
  static const Color primarySurface = Color(0xFF4340CA);

  // secondary colors
  static const Color secondary = Color(0xFF1DC533);
  static const Color secondarySurface = Color(0xFF008500);

  // semantic colors
  static const Color income = Color(0xFF1DC533);
  static const Color expense = Color(0xFFFF3437);
  static const Color error = Color(0xFFE50000);

  // background colors
  static const Color background = Color(0xFF121212);
  static const Color cardSurface = Color(0xFF191919);
  static const Color textfieldSurface = Color(0xFF2A2A2A);
  static const Color iconSurface = Color(0xFF454545);

  // text colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textDisabled = Color(0xFF52525B);

  // border colors
  static const Color borderColor = Color(0xFF262626);

  // gradient colors
  static const List<Color> incomeGradient = [
    Color(0xFF0F8300),
    Color(0xFF031C00),
  ];
  static const List<Color> expenseGradient = [
    Color(0xFFB50303),
    Color(0xFF250000),
  ];

  static const List<Color> fabGradient = [
    Color(0xFF1DC533),
    Color.fromARGB(255, 12, 91, 22),
    Color(0xFF031C00),
  ];
}

class AppTextStyles {
  AppTextStyles._();

  // display

  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.primaryText,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.primaryText,
  );

  // headings
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // body

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  // label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: AppColors.primaryText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.primaryText,
  );

  // button
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.primaryText,
  );
}

class AppDimensions {
  AppDimensions._();

  // spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 100.0;

  // item heights

  static const double buttonHeight = 52.0;
  static const double inputFieldHeight = 52.0;
  static const double bottomNavHeight = 74.0;
  static const double appBarHeight = 56.0;
  static const double fabSize = 56.0;
  static const double transactionTileHeight = 72.0;

  // icon sizes
  static const double iconSm = 18.0;
  static const double iconMd = 22.0;
  static const double iconLg = 26.0;
  static const double iconNav = 24.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryText,
      secondary: AppColors.primarySurface,
      onSecondary: AppColors.primaryText,
      error: AppColors.error,
      onError: AppColors.primaryText,
      surface: AppColors.cardSurface,
      onSurface: AppColors.primaryText,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: "Inter",

      // app bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingMedium,
      ),

      // bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.primaryText,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // card
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.borderColor, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),

      // elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryText,
          disabledBackgroundColor: AppColors.primarySurface,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 0,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
        ),
      ),

      // outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
        ),
      ),

      // fab
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondarySurface,
        foregroundColor: AppColors.primaryText,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.textfieldSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDisabled,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
        ),
        prefixIconColor: AppColors.primaryText,
        suffixIconColor: AppColors.primaryText,

        // Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 0.8,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 0.8,
          ),
        ),
        errorStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.expense),
      ),

      // list tile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.primaryText,
        textColor: AppColors.primaryText,
        subtitleTextStyle: AppTextStyles.bodySmall,
        titleTextStyle: AppTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.xs,
        ),
      ),

      // snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.iconSurface,
        contentTextStyle: AppTextStyles.bodyMedium,
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        elevation: 4,
      ),

      // text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }
}
