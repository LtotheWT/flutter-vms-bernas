import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_session_providers.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/info_row.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Future<void> _handleNavTap(int index) async {
    if (index != 2) {
      widget.navigationShell.goBranch(index);
      return;
    }

    await _showProfileSheet();
  }

  Future<void> _showProfileSheet() async {
    final session = await ref.read(authLocalDataSourceProvider).getSession();
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        var isLoggingOut = false;

        return StatefulBuilder(
          builder: (context, setState) {
            String displayValue(String? value) {
              final normalized = value?.trim() ?? '';
              return normalized.isEmpty ? '-' : normalized;
            }

            Future<void> onLogoutPressed() async {
              if (isLoggingOut) {
                return;
              }
              setState(() => isLoggingOut = true);
              try {
                await ref.read(authSessionControllerProvider).logout();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } finally {
                if (context.mounted) {
                  setState(() => isLoggingOut = false);
                }
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InfoRow(
                      label: 'Username',
                      value: displayValue(session?.username),
                    ),
                    InfoRow(
                      label: 'Full Name',
                      value: displayValue(session?.fullname),
                    ),
                    InfoRow(
                      label: 'Entity',
                      value: displayValue(session?.entity),
                    ),
                    InfoRow(
                      label: 'Default Site',
                      value: displayValue(session?.defaultSite),
                    ),
                    InfoRow(
                      label: 'Default Gate',
                      value: displayValue(session?.defaultGate),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isLoggingOut ? null : onLogoutPressed,
                        icon: const Icon(Icons.logout),
                        label: Text(isLoggingOut ? 'Logging out...' : 'Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}
