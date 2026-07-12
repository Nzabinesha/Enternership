import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/application.dart';

class ApplicantsScreen extends ConsumerWidget {
  final String opportunityId;
  const ApplicantsScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(startupApplicationsProvider(opportunityId));
    final oppAsync = ref.watch(opportunityByIdProvider(opportunityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(oppAsync.value?.title ?? 'Applicants'),
        bottom: oppAsync.value != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${oppAsync.value!.applicationCount} applicants',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              )
            : null,
      ),
      body: appsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text('No applications yet',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('Applications will appear here once students apply.',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (_, i) => _ApplicantCard(app: apps[i]),
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  final Application app;
  const _ApplicantCard({required this.app});

  static const _statusOptions = [
    (ApplicationStatus.applied, 'Applied', AppColors.statusApplied),
    (ApplicationStatus.reviewed, 'Under Review', AppColors.statusReviewed),
    (ApplicationStatus.interview, 'Interview', AppColors.statusInterview),
    (ApplicationStatus.accepted, 'Accept', AppColors.statusAccepted),
    (ApplicationStatus.rejected, 'Reject', AppColors.statusRejected),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _colorFor(app.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: app.studentPhotoUrl != null
                      ? NetworkImage(app.studentPhotoUrl!)
                      : null,
                  child: app.studentPhotoUrl == null
                      ? Text(
                          app.studentName
                              .split(' ')
                              .map((w) => w.isEmpty ? '' : w[0])
                              .take(2)
                              .join(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.studentName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(timeago.format(app.appliedAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(app.statusLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Cover letter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cover letter',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  app.coverLetter,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (app.portfolioUrl != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(app.portfolioUrl!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.primary),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _statusOptions.map((opt) {
                final (status, label, color) = opt;
                final isCurrent = app.status == status;
                return GestureDetector(
                  onTap: isCurrent
                      ? null
                      : () => _updateStatus(context, ref, status),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isCurrent ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: isCurrent ? color : AppColors.divider),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            isCurrent ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(ApplicationStatus s) {
    switch (s) {
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

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, ApplicationStatus newStatus) async {
    try {
      await ref.read(applicationRepositoryProvider).updateStatus(
            app.id,
            newStatus,
            studentId: app.studentId,
            opportunityTitle: app.opportunityTitle,
            startupName: app.startupName,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
