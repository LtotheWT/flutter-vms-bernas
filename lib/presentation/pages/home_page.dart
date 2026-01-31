import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Operations')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _SectionHeader(title: 'Invitations', textTheme: textTheme),
          _MenuTile(
            title: 'New Invitation',
            onTap: () => context.go(invitationAddRoutePath),
          ),
          const _MenuTile(title: 'Invitation Listing'),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Visitors', textTheme: textTheme),
          const _MenuTile(title: 'Visitor Registration (Walk-In) - No login'),
          const _MenuTile(title: 'Check-In'),
          const _MenuTile(title: 'Check-Out'),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Employees', textTheme: textTheme),
          const _MenuTile(title: 'Employee Check-In'),
          const _MenuTile(title: 'Employee Check-Out'),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Contractors', textTheme: textTheme),
          const _MenuTile(title: 'Permanent Contractor Check-In'),
          const _MenuTile(title: 'Permanent Contractor Check-Out'),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Whitelist', textTheme: textTheme),
          const _MenuTile(title: 'Whitelist Check-In'),
          const _MenuTile(title: 'Whitelist Check-Out'),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.textTheme});

  final String title;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
