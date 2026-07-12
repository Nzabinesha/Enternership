import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/application.dart';
import 'package:alu_enternership_pro/widgets/shimmer_loader.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My applications')),
      body: appsAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12), child: ShimmerCard()),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_outlined,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No applications yet',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Start exploring opportunities and apply to ones that match your skills.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.go('/discover'),
                      child: const Text('Browse opportunities'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Group by status
          final active = apps
              .where((a) =>
                  a.status != ApplicationStatus.accepted &&
                  a.status != ApplicationStatus.rejected)
              .toList();
          final closed = apps
              .where((a) =>
                  a.status == ApplicationStatus.accepted ||
                  a.status == ApplicationStatus.rejected)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary stats
              Row(
                children: [
                  _StatCard(
                      label: 'Total',
                      count: apps.length,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  _StatCard(
                      label: 'Active',
                      count: active.length,
                      color: AppColors.warning),
                  const SizedBox(width: 10),
                  _StatCard(
                      label: 'Accepted',
                      count: apps
                          .where((a) => a.status == ApplicationStatus.accepted)
                          .length,
                      color: AppColors.success),
                ],
              ),
              const SizedBox(height: 20),
              if (active.isNotEmpty) ...[
                Text('Active', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...active.map((a) => _AppCard(app: a)),
                const SizedBox(height: 20),
              ],
              if (closed.isNotEmpty) ...[
                Text('Closed', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...closed.map((a) => _AppCard(app: a)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatCard(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _AppCard extends ConsumerWidget {
  final Application app;
  const _AppCard({required this.app});

  Color _statusColor() {
    switch (app.status) {
      case ApplicationStatus.applied:
        return AppColors.statusApplied;
      case ApplicationStatus.reviewed:
        return AppColors.statusReviewed;
      case ApplicationStatus.interview:
        return AppColors.statusInterview;
      case ApplicationStatus.accepted:
        return AppColors.statusAccepted;
      case ApplicationStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.opportunityTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(app.startupName,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(app.statusLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          // Status timeline
          const SizedBox(height: 14),
          _StatusTimeline(currentStatus: app.status),
          if (app.founderNote != null && app.founderNote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(app.founderNote!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Applied \${timeago.format(app.appliedAt)}',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const Spacer(),
              if (app.status == ApplicationStatus.applied)
                GestureDetector(
                  onTap: () => _confirmWithdraw(context, ref),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw application'),
        content: Text(
            'Are you sure you want to withdraw your application for "\${app.opportunityTitle}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Withdraw',
                  style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref
          .read(applicationRepositoryProvider)
          .withdrawApplication(app.id, app.opportunityId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application withdrawn.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    }
  }
}

class _StatusTimeline extends StatelessWidget {
  final ApplicationStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  static const steps = [
    ApplicationStatus.applied,
    ApplicationStatus.reviewed,
    ApplicationStatus.interview,
    ApplicationStatus.accepted,
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStatus == ApplicationStatus.rejected) {
      return const Row(
        children: [
          Icon(Icons.cancel_outlined,
              size: 16, color: AppColors.statusRejected),
          SizedBox(width: 6),
          Text('Application not selected',
              style: TextStyle(fontSize: 12, color: AppColors.statusRejected)),
        ],
      );
    }

    final currentIdx = steps.indexOf(currentStatus);

    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final done = i <= currentIdx;
        final active = i == currentIdx;
        final color = done ? AppColors.success : AppColors.divider;

        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                    child: Container(
                        height: 2,
                        color: i <= currentIdx
                            ? AppColors.success
                            : AppColors.divider)),
              Container(
                width: active ? 10 : 8,
                height: active ? 10 : 8,
                decoration: BoxDecoration(
                  color: done ? AppColors.success : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (i < steps.length - 1) const SizedBox(width: 0),
            ],
          ),
        );
      }).toList(),
    );
  }
}
