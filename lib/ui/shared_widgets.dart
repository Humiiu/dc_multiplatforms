import 'package:flutter/material.dart';
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
            // Spacer to balance the 30dp help button on the right and keep DIAN CATERING centered
            const SizedBox(width: 30),
            Expanded(
              child: Center(
                child: Text(
                  'DIAN CATERING',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
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

    if (showBack) {
      return SizedBox(
        height: 48,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.welcome.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
              ),
            const SizedBox(width: 48),
          ],
        ),
      );
    }

    return const SizedBox(height: 48);
  }
}

class DemoPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double? fontSize;
  final double borderRadius;
  final bool isLoading;

  const DemoPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.fontSize,
    this.borderRadius = 14,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enabled
            ? (height < 45 ? AppShadows.buttonSoft : AppShadows.button)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: fontSize != null
                            ? AppTextStyles.buttonLarge
                                .copyWith(fontSize: fontSize)
                            : AppTextStyles.buttonLarge,
                      ),
                      if (icon != null) ...[
                        SizedBox(width: height < 45 ? 6 : 8),
                        Icon(
                          icon,
                          color: Colors.white,
                          size: fontSize != null ? (fontSize! * 1.15) : 19,
                        ),
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
