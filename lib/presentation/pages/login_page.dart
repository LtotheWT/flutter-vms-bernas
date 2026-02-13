import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/auth_session_entity.dart';
import '../app/router.dart';
import '../state/auth_session_providers.dart';
import '../state/login_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_text_form_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitted = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loginState = ref.watch(loginControllerProvider);

    ref.listen<AsyncValue<AuthSessionEntity?>>(loginControllerProvider, (
      previous,
      next,
    ) {
      final session = switch (next) {
        AsyncData<AuthSessionEntity?>(:final value) => value,
        _ => null,
      };
      if (_submitted && session != null) {
        ref.read(authSessionControllerProvider).markAuthenticated();
        context.go(homeRoutePath);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  AppTextFormField(
                    controller: _userIdController,
                    label: 'User ID',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    label: 'Password',
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppFilledButton(
                    onPressed: loginState.isLoading
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            _submitted = true;
                            await ref
                                .read(loginControllerProvider.notifier)
                                .login(
                                  userId: _userIdController.text,
                                  password: _passwordController.text,
                                );
                          },
                    child: loginState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 12),
                  loginState.when(
                    data: (_) => const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (error, _) => Text(
                      _toDisplayError(error),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _toDisplayError(Object error) {
    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'Login failed. Please try again.';
    }
    return text;
  }
}
