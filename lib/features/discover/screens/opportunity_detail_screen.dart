import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/opportunity.dart';
import 'package:alu_enternership_pro/core/models/application.dart';
import 'package:alu_enternership_pro/widgets/startup_avatar.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  final String opportunityId;
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oppAsync = ref.watch(opportunityByIdProvider(opportunityId));
    final user = ref.watch(currentUserProvider).value;
    final bookmarks = ref.watch(bookmarksProvider);

    return oppAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (opp) {
        if (opp == null)
          return const Scaffold(body: Center(child: Text('Not found')));

        final hasAppliedAsync = user != null
            ? ref.watch(hasAppliedProvider(
                (studentId: user.uid, opportunityId: opportunityId)))
            : null;
        final hasApplied = hasAppliedAsync?.value ?? false;
        final isBookmarked = bookmarks.contains(opportunityId);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                    onPressed: () => ref
                        .read(bookmarksProvider.notifier)
                        .toggle(opportunityId),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StartupAvatar(
                              name: opp.startupName,
                              logoUrl: opp.startupLogoUrl,
                              size: 52),
                          const SizedBox(height: 12),
                          Text(opp.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(opp.startupName,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              if (opp.startupVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified,
                                    color: Colors.white70, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _WhiteChip(
                                  label: opp.typeLabel,
                                  icon: Icons.work_outline),
                              _WhiteChip(
                                  label: opp.role,
                                  icon: Icons.category_outlined),
                              _WhiteChip(
                                  label: opp.isRemote
                                      ? 'Remote'
                                      : (opp.location ?? 'On-site'),
                                  icon: Icons.location_on_outlined),
                              _WhiteChip(
                                label: opp.isPaid
                                    ? (opp.compensation ?? 'Paid')
                                    : 'Unpaid',
                                icon: Icons.payments_outlined,
                                highlight: opp.isPaid,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Stats bar
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Duration',
                            value: opp.duration,
                            icon: Icons.timer_outlined,
                          ),
                          _Divider(),
                          _StatItem(
                            label: 'Deadline',
                            value: DateFormat('MMM d, y').format(opp.deadline),
                            icon: Icons.event_outlined,
                            highlight: opp.isExpired,
                          ),
                          _Divider(),
                          _StatItem(
                            label: 'Applicants',
                            value: '${opp.applicationCount}',
                            icon: Icons.people_outline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    _Section(
                      title: 'About this role',
                      child: Text(opp.description,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    // Skills
                    if (opp.requiredSkills.isNotEmpty)
                      _Section(
                        title: 'Required skills',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: opp.requiredSkills
                              .map((s) => Chip(
                                    label: Text(s),
                                    backgroundColor: AppColors.surfaceVariant,
                                    side: BorderSide.none,
                                  ))
                              .toList(),
                        ),
                      ),
                    // Startup section
                    _Section(
                      title: 'About the startup',
                      child: GestureDetector(
                        onTap: () => context.push('/startup/${opp.startupId}'),
                        child: Row(
                          children: [
                            StartupAvatar(
                                name: opp.startupName,
                                logoUrl: opp.startupLogoUrl,
                                size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(opp.startupName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  if (opp.startupVerified)
                                    const Row(children: [
                                      Icon(Icons.verified,
                                          size: 13, color: AppColors.success),
                                      SizedBox(width: 4),
                                      Text('ALU Verified',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.success)),
                                    ]),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: user?.isStudent == true
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: opp.isExpired
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                                child: Text('Deadline passed',
                                    style:
                                        TextStyle(color: AppColors.textMuted))),
                          )
                        : hasApplied
                            ? OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Application submitted'),
                              )
                            : ElevatedButton(
                                onPressed: () =>
                                    context.push('/apply/$opportunityId'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: AppColors.accent,
                                ),
                                child: const Text('Apply now'),
                              ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _WhiteChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlight;
  const _WhiteChip(
      {required this.label, required this.icon, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? AppColors.accent : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,
            size: 18, color: highlight ? AppColors.accent : AppColors.primary),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: highlight ? AppColors.accent : AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 36, width: 1, color: AppColors.divider);
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
