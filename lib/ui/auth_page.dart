import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/logo_widget.dart';
import 'shared_widgets.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isLoading = false;
  bool _registering = false;
  bool _obscurePassword = true;
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedKelas;
  String? _selectedJurusan;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSubmit() async {
    final authService = ref.read(authServiceProvider);

    // Fallback jika Firebase belum initialized (misal di test/offline mode)
    if (!authService.isFirebaseAvailable) {
      context.go('/home');
      return;
    }

    if (_registering) {
      final name = _nameController.text.trim();
      final username = _usernameController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text;

      if (name.isEmpty ||
          username.isEmpty ||
          phone.isEmpty ||
          password.isEmpty ||
          _selectedKelas == null ||
          _selectedJurusan == null) {
        _showDemoMessage('Mohon lengkapi semua field pendaftaran.');
        return;
      }

      if (password.length < 6) {
        _showDemoMessage('Password minimal 6 karakter.');
        return;
      }

      setState(() => _isLoading = true);
      try {
        await authService.register(
          name: name,
          username: username,
          phone: phone,
          kelas: KelasExtension.fromLabel(_selectedKelas!),
          jurusan: JurusanExtension.fromLabel(_selectedJurusan!),
          password: password,
        );
        if (mounted) {
          _showDemoMessage('Pendaftaran berhasil! Selamat datang, $name');
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          _showDemoMessage(e.toString().replaceAll('Exception: ', ''));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Login flow
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Izinkan langsung login jika kosong di mode demo/test
      if (username.isEmpty && password.isEmpty) {
        context.go('/home');
        return;
      }

      if (username.isEmpty || password.isEmpty) {
        _showDemoMessage('Masukkan username dan password.');
        return;
      }

      setState(() => _isLoading = true);
      try {
        await authService.signIn(
          username: username,
          password: password,
        );
        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          _showDemoMessage(e.toString().replaceAll('Exception: ', ''));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).height < 760;
    final buttonLabel = _registering ? 'Daftar' : 'Sign In';

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
                  const Center(child: AppLogo(size: 110)),
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
                  const SizedBox(height: 34),
                  if (_registering) ...[
                    _AuthInput(
                      hint: 'Fullname',
                      icon: null,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 10),
                    _AuthInput(
                      hint: 'Username',
                      icon: null,
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownInput<String>(
                            hint: 'Class',
                            value: _selectedKelas,
                            items: kelasOptions,
                            onChanged: (value) =>
                                setState(() => _selectedKelas = value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DropdownInput<String>(
                            hint: 'Major',
                            value: _selectedJurusan,
                            items: jurusanOptions,
                            onChanged: (value) =>
                                setState(() => _selectedJurusan = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _AuthInput(
                      hint: 'No Telp',
                      icon: null,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (!_registering) ...[
                    _AuthInput(
                      hint: 'Username',
                      icon: null,
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 10),
                  ],
                  _AuthInput(
                    hint: 'Password',
                    icon: _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    onIconPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  if (!_registering)
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
                    label: buttonLabel,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSubmit,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x339E003A),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
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
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const _AuthInput({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onIconPressed,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.inputText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        filled: false,
        isDense: true,
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

class _DropdownInput<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownInput({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.background,
      menuMaxHeight: 240,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        filled: false,
        fillColor: Colors.transparent,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(8, 15, 8, 10),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      icon:
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
      style: AppTextStyles.inputText,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: AppTextStyles.inputText,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
