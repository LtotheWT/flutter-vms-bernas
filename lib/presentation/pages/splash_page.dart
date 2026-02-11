import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../state/auth_session_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _resolveNextRoute);
  }

  Future<void> _resolveNextRoute() async {
    final useCase = ref.read(getPersistedSessionUseCaseProvider);

    try {
      final session = await useCase();
      if (!mounted) {
        return;
      }
      context.go(session == null ? loginRoutePath : homeRoutePath);
    } catch (_) {
      if (!mounted) {
        return;
      }
      context.go(loginRoutePath);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'VMS Bernas',
            style: textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
