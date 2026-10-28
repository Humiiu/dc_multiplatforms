import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class DemoTopBar extends StatelessWidget {
  final String? title;
  final bool showBack;
  final bool showBrand;
  final VoidCallback? onHelpTap;

  const DemoTopBar({
    super.key,
    this.title,
    this.showBack = false,
    this.showBrand = false,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    if (showBrand) {
      return SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x339E003A), width: 1),
                    image: const DecorationImage(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'DIAN CATERING',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onHelpTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0x339E003A),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          if (showBack)
            IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back),
            )
          else
            const SizedBox(width: 16),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                textAlign: showBack ? TextAlign.center : TextAlign.left,
                style: AppTextStyles.welcome.copyWith(
                  color: AppColors.primary,
                  fontSize: 24,
                ),
              ),
            )
          else
            const Spacer(),
          if (!showBack)
            IconButton(
              tooltip: 'Profil',
              onPressed: () => context.go('/profile'),
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Color(0xFFBDB6B4),
                size: 28,
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class DemoPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const DemoPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled ? AppShadows.button : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.buttonLarge),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: Colors.white, size: 19),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const DemoSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

String demoRupiah(int amount) {
  final digits = amount.toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'(?<=\d)(?=(\d{3})+$)'),
    (_) => '.',
  );
  return 'Rp $grouped';
}
