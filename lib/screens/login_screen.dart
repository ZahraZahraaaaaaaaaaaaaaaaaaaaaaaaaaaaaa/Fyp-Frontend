import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'user@training.local');
  final _password = TextEditingController(text: 'User123!');
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberDevice = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await context.read<AuthProvider>().login(_email.text.trim(), _password.text);
      if (mounted) context.go('/home');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF070B14), Color(0xFF0A1328)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -120,
              top: -30,
              child: Container(
                width: 520,
                height: 760,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.accentTeal.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, c) {
                  final narrow = c.maxWidth < 900;
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: narrow ? 16 : 24, vertical: 20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 980),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  _AuthBrandHeader(narrow: narrow),
                                  const SizedBox(height: 20),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 430),
                                    child: _LoginCard(
                                      formKey: _formKey,
                                      email: _email,
                                      password: _password,
                                      obscurePassword: _obscurePassword,
                                      rememberDevice: _rememberDevice,
                                      loading: _loading,
                                      error: _error,
                                      onToggleRemember: (v) => setState(() => _rememberDevice = v ?? false),
                                      onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                      onSubmit: _submit,
                                      onCreateAccount: () => context.go('/register'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _FooterCreateAccount(onCreateAccount: () => context.go('/register')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader({required this.narrow});

  final bool narrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accentTeal],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          'SecureLearn',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Advance your security expertise',
          style: const TextStyle(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscurePassword,
    required this.rememberDevice,
    required this.loading,
    required this.error,
    required this.onToggleRemember,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onCreateAccount,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscurePassword;
  final bool rememberDevice;
  final bool loading;
  final String? error;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: DesignTokens.shadowCard(Colors.black),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign in to your account',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your credentials to access the lab.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            const Text('Work Email', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'name@company.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Password', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: null,
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            TextFormField(
              controller: password,
              obscureText: obscurePassword,
              validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: onTogglePassword,
                  icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Checkbox(value: rememberDevice, onChanged: onToggleRemember),
                const Text('Remember this device', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sign in'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterCreateAccount extends StatelessWidget {
  const _FooterCreateAccount({required this.onCreateAccount});
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('New to the platform?', style: TextStyle(color: AppColors.textMuted)),
        TextButton(
          onPressed: onCreateAccount,
          child: const Text('Create an account'),
        ),
      ],
    );
  }
}
