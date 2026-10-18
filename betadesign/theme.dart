// lib/core/theme.dart
//
// Design tokens + ThemeData untuk Dian Catering.
// Sumber: home.png (frame 440 dp lebar, diekspor 4x). Semua angka dalam dp.
//
// Dependency: google_fonts  ->  flutter pub add google_fonts
//
// Tanda di komentar:
//   [terukur]  = diambil dari pixel PNG
//   [perkiraan] = ditebak dari gradasi / bentuk, cek di emulator

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// WARNA
// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // Permukaan
  static const Color surface = Color(0xFFFFF8F3); // background halaman, header, nav [terukur]
  static const Color card = Color(0xFFFFFFFF); // kartu debt & menu [terukur]
  static const Color secondaryContainer = Color(0xFFFFF2E0); // kartu "Punya request khusus?" [terukur]
  static const Color tertiaryContainer = Color(0xFFFFDEA5); // area gambar menu, tile bintang [terukur]
  static const Color blob = Color(0xFFF5DAD2); // dekorasi sudut kartu request [terukur]
  static const Color pillBg = Color(0xFFFFEADF); // pill indikator di kartu debt [terukur]
  static const Color chipBg = Color(0xE6FFFFFF); // chip hari = putih 90% [terukur]

  // Brand
  static const Color primary = Color(0xFF9E003A); // tombol utama [terukur]
  static const Color primaryDark = Color(0xFF740028); // teks/ikon bermerek: See All, chip, nav aktif [terukur]
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFF735C00); // ikon bintang [terukur]
  static const Color error = Color(0xFFBA1A1A); // titik merah di pill [terukur]

  // Teks
  static const Color ink = Color(0xFF261900); // judul [terukur]
  static const Color inkVariant = Color(0xFF594043); // teks sekunder, ikon nav tidak aktif [terukur]

  // Lain-lain
  static const Color avatarIcon = Color(0xFFB9B5B2); // ikon profil di header [terukur]
  static const Color outlineSoft = Color(0x1F9E003A); // border tombol "Atur Preferensi" (primary 12%) [perkiraan]

  // Glow dekoratif di kartu debt [perkiraan]
  static const Color glowWarm = Color(0x47FFDEA5); // kanan atas
  static const Color glowCool = Color(0x149E003A); // kiri bawah
  static const Color transparent = Color(0x00FFFFFF);
}

// ---------------------------------------------------------------------------
// SPACING (skala umum)
// ---------------------------------------------------------------------------
class AppSpace {
  AppSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20; // margin halaman [terukur]
  static const double xxl = 24;
  static const double xxxl = 32;
}

// ---------------------------------------------------------------------------
// RADIUS
// ---------------------------------------------------------------------------
class AppRadius {
  AppRadius._();

  static const double card = 32; // kartu debt & request [terukur ~30-33]
  static const double menuCard = 16; // kartu menu [terukur ~17]
  static const double tile = 16; // tile bintang [terukur]
  static const double buttonLg = 12; // Start Buying, Atur Preferensi [terukur]
  static const double buttonSm = 8; // Pay Now [terukur ~8-9]
  static const double nav = 20; // bar navigasi [perkiraan]
  static const double pill = 999;
}

// ---------------------------------------------------------------------------
// SHADOW
// ---------------------------------------------------------------------------
class AppShadows {
  AppShadows._();

  // Kartu putih (debt, menu): halus, kehitaman tipis [perkiraan]
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F594043), blurRadius: 16, offset: Offset(0, 4)),
  ];

  // Tombol "Pay Now" (primary ~25%) [perkiraan]
  static const List<BoxShadow> payButton = [
    BoxShadow(color: Color(0x409E003A), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // Tombol "Start Buying!" (primary ~30%, lebih lebar) [perkiraan]
  static const List<BoxShadow> ctaButton = [
    BoxShadow(color: Color(0x4D9E003A), blurRadius: 16, offset: Offset(0, 8)),
  ];

  // Tile bintang [perkiraan]
  static const List<BoxShadow> tile = [
    BoxShadow(color: Color(0x24735C00), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // Header & nav: garis bayangan sangat tipis [perkiraan]
  static const List<BoxShadow> bar = [
    BoxShadow(color: Color(0x0F594043), blurRadius: 8, offset: Offset(0, 2)),
  ];
}

// ---------------------------------------------------------------------------
// TIPOGRAFI
//   Judul  : Playfair Display
//   Isi/UI : Plus Jakarta Sans
// Ukuran dicocokkan ke lebar teks di PNG (toleransi ±3%). Weight = perkiraan.
// ---------------------------------------------------------------------------
class AppText {
  AppText._();

  // --- Playfair Display ---
  static TextStyle get greeting => GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.2);

  static TextStyle get amount => GoogleFonts.playfairDisplay(
        fontSize: 46, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.0);

  static TextStyle get sectionTitle => GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.2);

  // --- Plus Jakarta Sans ---
  static TextStyle get overline => GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5,
        color: AppColors.inkVariant, height: 1.2);

  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2,
        color: AppColors.inkVariant);

  static TextStyle get currency => GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.inkVariant);

  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.inkVariant, height: 1.5);

  static TextStyle get menuTitle => GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.3);

  static TextStyle get menuSub => GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.inkVariant, height: 1.35);

  static TextStyle get chip => GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryDark, height: 1.3);

  static TextStyle get link => GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryDark);

  static TextStyle get buttonSm => GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onPrimary, letterSpacing: 0.3);

  static TextStyle get buttonLg => GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary, letterSpacing: 0.3);

  static TextStyle get buttonOutlined => GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryDark, letterSpacing: 0.3);

  static TextStyle get nav => GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.inkVariant, height: 1.2);

  static TextStyle get navActive => GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark, height: 1.2);
}

// ---------------------------------------------------------------------------
// THEME
// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ColorScheme.fromSeed(seedColor: AppColors.primary);
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: base.copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );
  }
}