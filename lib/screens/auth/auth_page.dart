import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/logo_widget.dart' show AppLogo, normalizeIndonesianPhone, PhoneInputFormatter;

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  Jurusan _selectedJurusan = Jurusan.rpl;
  Kelas _selectedKelas = Kelas.x;

  bool _isRegistering = false; // true = registrasi, false = login
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Track which fields have been touched for validation display
  final Set<String> _touchedFields = {};

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  /// Register directly — no OTP, just create account
  Future<void> _register() async {
    // Mark all fields as touched
    setState(() => _touchedFields.addAll([
      'phone', 'username', 'name', 'password', 'confirmPassword',
    ]));

    // Validate
    final rawPhone = _phoneCtrl.text.trim();
    final normalized = normalizeIndonesianPhone(rawPhone);
    if (normalized == null) {
      setState(() => _errorMessage = AppConstants.errPhoneInvalid);
      return;
    }
    if (_usernameCtrl.text.trim().length < 3) {
      setState(() => _errorMessage = AppConstants.errUsernameTooShort);
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = AppConstants.errNameEmpty);
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _errorMessage = AppConstants.errPasswordTooShort);
      return;
    }
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _errorMessage = AppConstants.errPasswordNoMatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = ref.read(databaseServiceProvider);
      final authService = ref.read(authServiceProvider);

      // Check if phone is already registered
      final isPhoneTaken = await db.isPhoneRegistered(normalized);
      if (isPhoneTaken) {
        throw Exception('Nomor telepon sudah terdaftar');
      }

      // Check if username is taken
      final isTaken = await db.isUsernameTaken(_usernameCtrl.text.trim());
      if (isTaken) {
        throw Exception('Username sudah digunakan');
      }

      // Generate the UID-based email directly to avoid 'recent-login' errors on updateEmail
      // We don't have the UID yet, so we use a placeholder or a deterministic format if possible.
      // Actually, we can just use the phone number as the basis for the email.
      final loginEmail = '${normalized.replaceAll('+', '')}@catering.app';

      User? user;
      try {
        user = await authService.createUserWithEmailAndPassword(
          loginEmail,
          _passwordCtrl.text,
        );
      } catch (e) {
        throw Exception('Gagal membuat akun: $e');
      }

      final uid = user?.uid;
      if (uid == null) {
        throw Exception('Gagal mendapatkan UID');
      }

      try {
        // Register user data in Realtime Database
        await authService.registerUser(
          uid: uid,
          username: _usernameCtrl.text.trim(),
          phone: normalized,
          name: _nameCtrl.text.trim(),
          jurusan: _selectedJurusan,
          kelas: _selectedKelas,
        );
      } catch (e) {
        // CLEANUP: If DB registration fails, delete the auth user to avoid orphans
        await user?.delete();
        throw Exception('Registrasi database gagal: $e');
      }

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Login with phone + password
  Future<void> _loginWithPassword() async {
    // Mark all fields as touched for login
    setState(() => _touchedFields.addAll(['phone', 'password']));

    final rawPhone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (rawPhone.isEmpty || password.isEmpty) {
      // Errors will be shown by field-level validation via _getFieldError
      setState(() => _errorMessage = null);
      return;
    }

    final normalized = normalizeIndonesianPhone(rawPhone);
    if (normalized == null) {
      setState(() => _errorMessage = AppConstants.errPhoneInvalid);
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = AppConstants.errPasswordTooShort);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
            normalized,
            password,
          );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _markFieldTouched(String field) {
    setState(() => _touchedFields.add(field));
  }

  String? _getFieldError(String field) {
    if (!_touchedFields.contains(field)) return null;

    switch (field) {
      case 'phone':
        final raw = _phoneCtrl.text.trim();
        if (raw.isEmpty) return AppConstants.errPhoneEmpty;
        if (normalizeIndonesianPhone(raw) == null) return AppConstants.errPhoneInvalid;
        return null;
      case 'username':
        final username = _usernameCtrl.text.trim();
        if (username.isEmpty) return AppConstants.errUsernameEmpty;
        if (username.length < 3) return AppConstants.errUsernameTooShort;
        return null;
      case 'name':
        if (_nameCtrl.text.trim().isEmpty) return AppConstants.errNameEmpty;
        return null;
      case 'password':
        if (_passwordCtrl.text.isEmpty) return 'Password tidak boleh kosong';
        if (_passwordCtrl.text.length < 6) return AppConstants.errPasswordTooShort;
        return null;
      case 'confirmPassword':
        if (_passwordCtrl.text != _confirmPasswordCtrl.text) return AppConstants.errPasswordNoMatch;
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLogo(size: 90),
                const SizedBox(height: 24),
                Text(
                  'WELCOME',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.welcome,
                ),
                const SizedBox(height: 44),

                // Login/Register toggle tabs
                _buildTabSwitcher(),
                const SizedBox(height: 48),

                // Form fields
                if (!_isRegistering) ...[
                  // ── LOGIN ──
                  _buildInputField(
                    controller: _phoneCtrl,
                    label: 'Nomor Telepon',
                    hintText: '',
                    keyboardType: TextInputType.phone,
                    prefixIcon: null,
                    fieldKey: 'phone',
                    leadingText: '+62 ',
                    digitsOnly: true,
                    formatters: [PhoneInputFormatter()],
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hintText: 'Masukkan password',
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePassword,
                    prefixIcon: null,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    fieldKey: 'password',
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('blom ada fitur nya')),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      child: const Text('lupa password?'),
                    ),
                  ),
                ] else ...[
                  // ── REGISTER ──
                  _buildInputField(
                    controller: _phoneCtrl,
                    label: 'Nomor Telepon',
                    hintText: '',
                    keyboardType: TextInputType.phone,
                    prefixIcon: null,
                    fieldKey: 'phone',
                    digitsOnly: true,
                    formatters: [PhoneInputFormatter()],
                    leadingText: '+62 ',
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _usernameCtrl,
                    label: 'Username',
                    hintText: 'Buat username',
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.person_outline,
                    fieldKey: 'username',
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _nameCtrl,
                    label: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap',
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.badge_outlined,
                    fieldKey: 'name',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 12.0;
                      const minDropdownWidth = 140.0;
                      final fitsSideBySide =
                          (constraints.maxWidth - gap) >= minDropdownWidth * 2;
                      if (fitsSideBySide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildDropdown<Jurusan>(
                                label: 'Jurusan',
                                value: _selectedJurusan,
                                items: Jurusan.values,
                                itemLabel: (j) => j.label,
                                onChanged: (v) =>
                                    setState(() => _selectedJurusan = v!),
                                prefixIcon: Icons.school_outlined,
                              ),
                            ),
                            const SizedBox(width: gap),
                            Expanded(
                              flex: 2,
                              child: _buildDropdown<Kelas>(
                                label: 'Kelas',
                                value: _selectedKelas,
                                items: Kelas.values,
                                itemLabel: (k) => k.label,
                                onChanged: (v) =>
                                    setState(() => _selectedKelas = v!),
                                prefixIcon: Icons.class_outlined,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildDropdown<Jurusan>(
                            label: 'Jurusan',
                            value: _selectedJurusan,
                            items: Jurusan.values,
                            itemLabel: (j) => j.label,
                            onChanged: (v) => setState(() => _selectedJurusan = v!),
                            prefixIcon: Icons.school_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown<Kelas>(
                            label: 'Kelas',
                            value: _selectedKelas,
                            items: Kelas.values,
                            itemLabel: (k) => k.label,
                            onChanged: (v) => setState(() => _selectedKelas = v!),
                            prefixIcon: Icons.class_outlined,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hintText: 'Minimal 6 karakter',
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    fieldKey: 'password',
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _confirmPasswordCtrl,
                    label: 'Konfirmasi Password',
                    hintText: 'Ulangi password',
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    fieldKey: 'confirmPassword',
                  ),
                ],

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Field-level errors
                ..._buildFieldErrors(),

                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : (_isRegistering ? _register : _loginWithPassword),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: AppTextStyles.buttonSignIn,
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(AppColors.primary),
                      shadowColor: WidgetStateProperty.all(const Color(0x269E013A)),
                      elevation: WidgetStateProperty.all(0),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(_isRegistering ? 'Buat Akun' : 'Sign In'),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFieldErrors() {
    final fields = <String>[];

    if (!_isRegistering) {
      fields.addAll(['phone', 'password']);
    } else {
      fields.addAll(['phone', 'username', 'name', 'password', 'confirmPassword']);
    }

    return fields.map((field) {
      final error = _getFieldError(field);
      if (error == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: ShapeDecoration(
        color: AppColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        shadows: AppShadows.subtle,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _isRegistering ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              width: 188,
              height: 44,
              margin: const EdgeInsets.all(4),
              decoration: ShapeDecoration(
                color: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                shadows: [
                  BoxShadow(
                    color: const Color(0x19000000),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: const Color(0x19000000),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                    spreadRadius: -1,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: Center(child: _buildTabLabel('Login', isActive: !_isRegistering))),
              Expanded(child: Center(child: _buildTabLabel('Register', isActive: _isRegistering))),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _isRegistering = false),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _isRegistering = true),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabLabel(String text, {required bool isActive}) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        height: 1.43,
        letterSpacing: 0.7,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
        color: isActive ? Colors.white : AppColors.textPrimary,
      ),
      child: Text(text, textAlign: TextAlign.center),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? leadingText,
    bool digitsOnly = false,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    VoidCallback? onSuffixTap,
    ValueChanged<String>? onChanged,
    String? fieldKey,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    final hasError = fieldKey != null && _getFieldError(fieldKey) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0),
          child: Text(
            label,
            style: AppTextStyles.inputHint.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(
                color: hasError ? AppColors.error : AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                maxLength: maxLength,
                style: AppTextStyles.inputText,
                inputFormatters: formatters ??
                    (digitsOnly
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : null),
                onSubmitted: onFieldSubmitted,
                onChanged: onChanged,
                onTap: () {
                  if (fieldKey != null) _markFieldTouched(fieldKey);
                },
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppTextStyles.inputHint.copyWith(
                    color: hasError ? AppColors.error.withValues(alpha: 0.5) : AppColors.textSecondary,
                  ),
                  prefixText: leadingText,
                  prefixStyle: AppTextStyles.inputText.copyWith(
                    color: hasError ? AppColors.error : AppColors.textPrimary,
                  ),
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: hasError ? AppColors.error : AppColors.textSecondary, size: 20)
                      : null,
                  suffixIcon: suffixIcon != null
                      ? IconButton(
                          icon: Icon(suffixIcon, color: hasError ? AppColors.error : AppColors.textSecondary, size: 20),
                          onPressed: onSuffixTap,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        )
                      : null,
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0),
          child: Text(
            label,
            style: AppTextStyles.inputHint.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: const BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              isDense: true,
            ),
            style: AppTextStyles.inputText,
            dropdownColor: Colors.white,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item), style: AppTextStyles.inputText),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
