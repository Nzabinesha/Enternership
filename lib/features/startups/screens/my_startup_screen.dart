import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/widgets/startup_avatar.dart';

class MyStartupScreen extends ConsumerWidget {
  const MyStartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(myStartupProvider);

    return startupAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (startup) {
        if (startup == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('My Startup')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.rocket_launch_outlined,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('Register your startup',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your startup profile to post opportunities and connect with talented ALU students.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/create-startup'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create startup profile'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                title: Text(startup.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        context.push('/edit-startup/${startup.id}'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: Row(
                        children: [
                          StartupAvatar(
                              name: startup.name,
                              logoUrl: startup.logoUrl,
                              size: 56),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(startup.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                    if (startup.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified,
                                          color: Colors.white70, size: 16),
                                    ],
                                  ],
                                ),
                                Text(startup.tagline,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                    maxLines: 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Verification banner
                    if (!startup.isVerified)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.hourglass_empty,
                                color: AppColors.warning, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Verification pending. You can post opportunities once ALU admin verifies your startup.',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _StatTile(
                              label: 'Opportunities',
                              value: '${startup.opportunityCount}'),
                          const SizedBox(width: 10),
                          _StatTile(label: 'Industry', value: startup.industry),
                          const SizedBox(width: 10),
                          _StatTile(
                              label: 'Status',
                              value:
                                  startup.isVerified ? 'Verified' : 'Pending',
                              valueColor: startup.isVerified
                                  ? AppColors.success
                                  : AppColors.warning),
                        ],
                      ),
                    ),
                    // Post opportunity CTA
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: startup.isVerified
                            ? () =>
                                context.push('/post-opportunity/${startup.id}')
                            : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Post new opportunity'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppColors.accent,
                        ),
                      ),
                    ),
                    // Posted opportunities
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Your opportunities',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ),
                    Consumer(builder: (context, ref, _) {
                      final oppsAsync =
                          ref.watch(startupOpportunitiesProvider(startup.id));
                      return oppsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('$e'),
                        data: (opps) {
                          if (opps.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No opportunities posted yet.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            );
                          }
                          return Column(
                            children: opps
                                .map((o) => _OppManageTile(
                                      title: o.title,
                                      role: o.role,
                                      isActive: o.isActive,
                                      applicants: o.applicationCount,
                                      onView: () =>
                                          context.push('/applicants/${o.id}'),
                                    ))
                                .toList(),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.primary)),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _OppManageTile extends StatelessWidget {
  final String title;
  final String role;
  final bool isActive;
  final int applicants;
  final VoidCallback onView;
  const _OppManageTile(
      {required this.title,
      required this.role,
      required this.isActive,
      required this.applicants,
      required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('$role · $applicants applicants',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          TextButton(onPressed: onView, child: const Text('View')),
        ],
      ),
    );
  }
}
