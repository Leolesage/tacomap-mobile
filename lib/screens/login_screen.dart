import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loader.dart';

class LoginScreen extends StatefulWidget {
  final bool popOnSuccess;

  const LoginScreen({super.key, this.popOnSuccess = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@tacomap.local');
  final _passwordController = TextEditingController(text: 'Password123!');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
      return;
    }
    if (auth.isAuthenticated && widget.popOnSuccess) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const AppLoader(message: 'Signing in...');
          }

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.restaurant, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'TACOMAP FRANCE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Admin login',
                          style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: 'admin@tacomap.local',
                                prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppTheme.textMuted),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Email required.';
                                if (!value.contains('@')) return 'Invalid email.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                hintText: 'Password123!',
                                prefixIcon: Icon(Icons.lock_outline, size: 18, color: AppTheme.textMuted),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  (value == null || value.isEmpty) ? 'Password required.' : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

