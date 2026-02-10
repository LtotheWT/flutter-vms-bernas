import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Operations'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: ColoredBox(
              color: colorScheme.surface,
              child: TabBar(
                tabs: const [
                  Tab(text: 'Invitations'),
                  Tab(text: 'Visitors'),
                  Tab(text: 'Workforce'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _SectionList(
              children: [
                _SectionCard(
                  title: 'Invitation Management',
                  icon: Icons.mail_outline,
                  color: colorScheme.primaryContainer,
                  children: [
                    _MenuTile(
                      title: 'New Invitation',
                      onTap: () => context.push(invitationAddRoutePath),
                    ),
                    _MenuTile(
                      title: 'Invitation Listing',
                      onTap: () => context.push(invitationListingRoutePath),
                    ),
                  ],
                ),
              ],
            ),
            _SectionList(
              children: [
                // _SectionCard(
                //   title: 'Visitor Registration',
                //   icon: Icons.badge_outlined,
                //   color: colorScheme.secondaryContainer,
                //   children: [
                //     _MenuTile(
                //       title: 'Visitor Registration (Walk-In)',
                //       onTap: () => context.push(visitorWalkInRoutePath),
                //     ),
                //   ],
                // ),
                _SectionCard(
                  title: 'Visitor Access',
                  icon: Icons.login_rounded,
                  color: colorScheme.primaryContainer,
                  children: [
                    _MenuTile(
                      title: 'Check-In',
                      onTap: () => context.push(visitorCheckInRoutePath),
                    ),
                    _MenuTile(
                      title: 'Check-Out',
                      onTap: () => context.push(visitorCheckOutRoutePath),
                    ),
                  ],
                ),
                _SectionCard(
                  title: 'Whitelist',
                  icon: Icons.verified_user_outlined,
                  color: colorScheme.primaryContainer,
                  children: const [
                    _MenuTile(title: 'Whitelist Check-In'),
                    _MenuTile(title: 'Whitelist Check-Out'),
                  ],
                ),
              ],
            ),
            _SectionList(
              children: [
                _SectionCard(
                  title: 'Employees',
                  icon: Icons.badge_outlined,
                  color: colorScheme.tertiaryContainer,
                  children: const [
                    _MenuTile(title: 'Employee Check-In'),
                    _MenuTile(title: 'Employee Check-Out'),
                  ],
                ),
                _SectionCard(
                  title: 'Permanent Contractors',
                  icon: Icons.construction_outlined,
                  color: colorScheme.secondaryContainer,
                  children: const [
                    _MenuTile(title: 'Permanent Contractor Check-In'),
                    _MenuTile(title: 'Permanent Contractor Check-Out'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemCount: children.length,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
