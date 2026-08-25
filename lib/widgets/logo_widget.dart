import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Logo widget matching Figma design:
/// - Circular with soft border #5E6E0129 (subtle)
/// - Soft shadow: black ~15%, blur 8, offset (-3, 3) — refined from Figma's
///   harsher 25%/blur4 so it doesn't read as a rough gray ring on-device.
class AppLogo extends StatelessWidget {
  final double size;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow> shadows;

  const AppLogo({
    super.key,
    this.size = 110,
    this.borderWidth = 1,
    this.borderColor = AppColors.borderStrong,
    this.shadows = const [
      BoxShadow(
        color: Color(0x26000000), // black 15% — soft, not a gray blob
        blurRadius: 8,
        offset: Offset(-3, 3),
        spreadRadius: 0,
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/logo.png'),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: borderWidth,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        shadows: shadows,
      ),
    );
  }
}

/// Alternative logo with icon if asset not available
class AppLogoFallback extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  const AppLogoFallback({
    super.key,
    this.size = 110,
    this.backgroundColor = const Color(0xFFFFE5B9),
    this.icon = Icons.restaurant_menu,
    this.iconColor = const Color(0xFF9E003A),
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0x5E6E0129),
          ),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(-4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}

/// Normalizes Indonesian phone numbers to +62 format for Firebase.
/// Accepted inputs (after stripping spaces/dashes/parens):
///   8999107194   -> +628999107194
///   08999107194  -> +628999107194
///   +628999107194 -> +628999107194
///   628999107194 -> +628999107194
/// Returns null if the number is not a valid ID mobile number.
String? normalizeIndonesianPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[\s\-().]'), '');

  if (digits.startsWith('+62')) {
    digits = digits.substring(3);
  } else if (digits.startsWith('62')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  // Now digits should start with '8' (mobile prefix)

  if (digits.isEmpty || !digits.startsWith('8')) return null;
  // Indonesian mobile: 8xx followed by 7-10 more digits (total 9-12)
  if (digits.length < 9 || digits.length > 12) return null;
  if (!RegExp(r'^\d+$').hasMatch(digits)) return null;

  return '+62$digits';
}