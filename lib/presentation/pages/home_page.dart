import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SectionCard(
            title: 'Invitations',
            color: colorScheme.primaryContainer,
            icon: Icons.mail_outline,
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
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Visitors',
            color: colorScheme.secondaryContainer,
            icon: Icons.group_outlined,
            children: [
              _MenuTile(
                title: 'Visitor Registration (Walk-In) - No login',
                onTap: () => context.push(visitorWalkInRoutePath),
              ),
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
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Employees',
            color: colorScheme.tertiaryContainer,
            icon: Icons.badge_outlined,
            children: const [
              _MenuTile(title: 'Employee Check-In'),
              _MenuTile(title: 'Employee Check-Out'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Contractors',
            color: colorScheme.primaryContainer.withOpacity(0.6),
            icon: Icons.construction_outlined,
            children: const [
              _MenuTile(title: 'Permanent Contractor Check-In'),
              _MenuTile(title: 'Permanent Contractor Check-Out'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Whitelist',
            color: colorScheme.secondaryContainer.withOpacity(0.6),
            icon: Icons.verified_user_outlined,
            children: const [
              _MenuTile(title: 'Whitelist Check-In'),
              _MenuTile(title: 'Whitelist Check-Out'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.children,
  });

  final String title;
  final Color color;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
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
