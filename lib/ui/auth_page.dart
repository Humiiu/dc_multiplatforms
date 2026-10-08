import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../widgets/logo_widget.dart';
import 'shared_widgets.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _registering = false;
  bool _obscurePassword = true;

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).height < 760;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                children: [
                  SizedBox(height: isCompact ? 14 : 48),
                  const AppLogo(size: 110),
                  const SizedBox(height: 20),
                  Text(
                    'WELCOME',
                    style: AppTextStyles.welcome.copyWith(
                      fontSize: 28,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _AuthTab(
                          title: 'Login',
                          selected: !_registering,
                          onTap: () => setState(() => _registering = false),
                        ),
                        _AuthTab(
                          title: 'Register',
                          selected: _registering,
                          onTap: () => setState(() => _registering = true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 42),
                  if (_registering) ...[
                    _AuthInput(hint: 'Username', icon: null),
                    const SizedBox(height: 8),
                  ],
                  _AuthInput(hint: 'Email or Phone', icon: null),
                  const SizedBox(height: 8),
                  _AuthInput(
                    hint: 'Password',
                    icon: _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    obscureText: _obscurePassword,
                    onIconPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          _showDemoMessage('Lupa password belum terhubung.'),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DemoPrimaryButton(
                    label: 'Sign In',
                    onPressed: () => context.go('/home'),
                  ),
                  SizedBox(height: isCompact ? 54 : 180),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: AppColors.iconGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tampilan demo • belum terhubung ke backend',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _AuthTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: selected ? AppColors.primary : Colors.transparent,
            foregroundColor: selected ? Colors.white : AppColors.textPrimary,
            elevation: selected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(title, style: AppTextStyles.bodyMediumBold),
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final VoidCallback? onIconPressed;

  const _AuthInput({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText: hint,
        filled: false,
        contentPadding: const EdgeInsets.fromLTRB(8, 15, 8, 10),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        suffixIcon: icon == null
            ? null
            : IconButton(
                onPressed: onIconPressed,
                icon: Icon(icon, color: AppColors.textSecondary, size: 20),
              ),
      ),
    );
  }
}
