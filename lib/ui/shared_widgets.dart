import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class DemoTopBar extends StatelessWidget {
  final String? title;
  final bool showBack;

  const DemoTopBar({super.key, this.title, this.showBack = false});

  @override
  Widget build(BuildContext context) {
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 8,
          shadowColor: AppColors.shadowPrimaryStrong,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.buttonLarge),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 19),
            ],
          ],
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
