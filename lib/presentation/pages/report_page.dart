import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _ReportCard(
            title: 'Visitor Log',
            subtitle: 'View visitor entries and exits.',
            icon: Icons.badge_outlined,
            color: colorScheme.primaryContainer,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Employee Log',
            subtitle: 'Track employee check-in/out history.',
            icon: Icons.work_outline,
            color: colorScheme.secondaryContainer,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Permanent Contractor Log',
            subtitle: 'Review contractor access logs.',
            icon: Icons.construction_outlined,
            color: colorScheme.tertiaryContainer,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Dashboard',
            subtitle: 'Key metrics and summaries.',
            icon: Icons.insert_chart_outlined,
            color: colorScheme.primaryContainer.withOpacity(0.6),
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.textTheme,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
