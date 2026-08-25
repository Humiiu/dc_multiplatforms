import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from Figma export (D:\download\tes\flutter.txt).
/// Color palette, gradients, typography, shadows, radius, spacing.
class AppColors {
  // Surfaces
  static const background = Color(0xFFFFF8F3); // cream
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFFFF2E0); // light cream for cards

  // Primary (maroon)
  static const primary = Color(0xFF9E003A);
  static const primaryDark = Color(0xFF740028);
  static const primaryLight = Color(0xFFFFDEA5); // light accent bg

  // Secondary (yellow/gold)
  static const secondary = Color(0xFFFFF0CA);
  static const accent = Color(0xFFFFE5B9);
  static const gold = Color(0xFFFECF15);

  // Text
  static const textPrimary = Color(0xFF261900); // dark brown
  static const textSecondary = Color(0xFF594043); // gray brown
  static const textOnPrimary = Colors.white;
  static const textMuted = Color(0xFF594043);

  // Border / input
  static const border = Color(0xFFE1BEC1); // soft maroon border
  static const borderStrong = Color(0x5E6E0129);
  static const divider = Color(0x4CE1BEC1);

  // Status
  static const success = Color(0xFFBA1A1A); // used for red dot in tagihan
  static const error = Color(0xFFBA1A1A);
  static const warning = Color(0xFFFFB800);

  // Icon
  static const iconGold = Color(0xFF735C00);

  // Shadows
  static const shadowSubtle = Color(0x0C000000);
  static const shadowCard = Color(0x19000000);
  static const shadowPrimary = Color(0x269E013A);
  static const shadowPrimaryStrong = Color(0x4C740028);
  static const shadowPrimaryButton = Color(0x33740028);

  // Gradients
  static const gradientPrimary = LinearGradient(
    begin: Alignment(0.00, 0.50),
    end: Alignment(1.00, 0.50),
    colors: [Color(0xFFFECF15), Color(0xFF9E013A)],
  );

  static const gradientImageOverlay = LinearGradient(
    begin: Alignment(0.50, 1.00),
    end: Alignment(0.50, 0.00),
    colors: [Colors.white, Colors.white, Colors.white], // white fade
    stops: [0.0, 0.5, 1.0],
  );

  static const gradientTagihanBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF2E0), Color(0xFFFFF8F3)],
  );

  static const gradientButtonPrimary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9E003A), Color(0xFF740028)],
  );

  AppColors._();
}

/// Border radius tokens
class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const round = 999.0;

  AppRadius._();
}

/// Shadow tokens from Figma
class AppShadows {
  static const subtle = [
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x19000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x19000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
  ];

  static const cardElevated = [
    BoxShadow(
      color: Color(0x0F9E013A),
      blurRadius: 24,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const buttonPrimary = [
    BoxShadow(
      color: Color(0x269E013A),
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const buttonPrimaryStrong = [
    BoxShadow(
      color: Color(0x4C740028),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const inputFocus = [
    BoxShadow(
      color: Color(0x199E013A),
      blurRadius: 0,
      offset: Offset(0, 0),
      spreadRadius: 1,
    ),
  ];

  AppShadows._();
}

/// Typography tokens using Google Fonts
/// Headers: Playfair Display
/// Body: Plus Jakarta Sans
/// Buttons: Plus Jakarta Sans (w600)
/// Sign In button: Montserrat (w700)
class AppTextStyles {
  // Header "WELCOME" / "SELAMAT DATANG" — Playfair Display w700, 28, primaryDark
  static TextStyle get welcome => GoogleFonts.playfairDisplay(
        color: AppColors.primaryDark,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        letterSpacing: 0.5,
      );

  // Section title (e.g. "Menu Minggu Ini", "Your Order", "Order Summary") — Playfair Display w600, 24
  static TextStyle get sectionTitle => GoogleFonts.playfairDisplay(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      );

  // Large price — Playfair Display w700, 48, textPrimary
  static TextStyle get priceLarge => GoogleFonts.playfairDisplay(
        color: AppColors.textPrimary,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.17,
        letterSpacing: -0.96,
      );

  // Medium price — Playfair Display w600, 24
  static TextStyle get priceMedium => GoogleFonts.playfairDisplay(
        color: AppColors.primary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      );

  // Body large 16 w400 — Plus Jakarta Sans
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  // Body medium 14 w500/w600 — Plus Jakarta Sans
  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMediumBold => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.7,
        color: AppColors.textPrimary,
      );

  // Body small 14 w400 — Plus Jakarta Sans
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  // Label 12 w500 — Plus Jakarta Sans
  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  // Button label 14 w600 letter-spacing 0.7 — Plus Jakarta Sans
  static TextStyle get button => GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.7,
      );

  // Sign In button — Montserrat w700
  static TextStyle get buttonSignIn => GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.43,
        letterSpacing: 0.7,
      );

  // Pesan Ketring button — Plus Jakarta Sans w600, 16
  static TextStyle get buttonLarge => GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.4,
      );

  // Caption 12 w400
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  // Input field text
  static TextStyle get inputText => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  // Input hint text
  static TextStyle get inputHint => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  // Tab/nav label
  static TextStyle get navLabel => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  static TextStyle get navLabelSelected => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: AppColors.primaryDark,
      );

  AppTextStyles._();
}

/// Spacing tokens
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  AppSpacing._();
}

/// Main theme builder
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    surface: AppColors.background,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: AppColors.primaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.29,
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: EdgeInsets.zero,
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: AppTextStyles.inputHint,
      labelStyle: AppTextStyles.inputHint,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.shadowPrimaryButton,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),

    // Filled button theme (primary actions)
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTextStyles.button,
        elevation: 4,
        shadowColor: AppColors.shadowPrimaryButton,
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.2),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.bodyMediumBold.copyWith(
          color: AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),

    // Navigation bar theme (bottom nav)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.accent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return selected ? AppTextStyles.navLabelSelected : AppTextStyles.navLabel;
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          size: 24,
        );
      }),
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryDark,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: AppTextStyles.bodyMediumBold,
      unselectedLabelStyle: AppTextStyles.bodyMedium,
      dividerColor: Colors.transparent,
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.accent,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.border,
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      secondaryLabelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      brightness: Brightness.light,
    ),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      titleTextStyle: AppTextStyles.bodyMediumBold,
      subtitleTextStyle: AppTextStyles.bodySmall,
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
    ),

    // Snack bar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      actionTextColor: AppColors.gold,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      modalBackgroundColor: Colors.white,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      titleTextStyle: AppTextStyles.sectionTitle,
      contentTextStyle: AppTextStyles.bodyMedium,
    ),
  );
}