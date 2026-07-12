import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';

class _OpportunitySummaryCard extends StatelessWidget {
  final dynamic opportunity;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _OpportunitySummaryCard({
    required this.opportunity,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final title = opportunity?.title ?? opportunity?.name ?? 'Opportunity';
    final description = opportunity?.description ?? '';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.toString(),
                        style: Theme.of(context).textTheme.titleSmall),
                    if (description.toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onBookmark,
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartupDetailScreen extends ConsumerWidget {
  final String startupId;
  const StartupDetailScreen({super.key, required this.startupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(startupByIdProvider(startupId));
    final oppsAsync = ref.watch(startupOpportunitiesProvider(startupId));
    final bookmarks = ref.watch(bookmarksProvider);

    return startupAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (startup) {
        if (startup == null) {
          return const Scaffold(body: Center(child: Text('Startup not found')));
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                expandedHeight: 200,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop()),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white24,
                          backgroundImage: startup.logoUrl != null
                              ? NetworkImage(startup.logoUrl!)
                              : null,
                          child: startup.logoUrl == null
                              ? Text(
                                  startup.name.isNotEmpty
                                      ? startup.name[0].toUpperCase()
                                      : '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(startup.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        if (startup.isVerified)
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 14, color: Colors.white70),
                              SizedBox(width: 4),
                              Text('ALU Verified',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags row
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(startup.industry)),
                          if (startup.aluCohort != null)
                            Chip(label: Text(startup.aluCohort!)),
                        ],
                      ),
                    ),
                    // Tagline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(startup.tagline,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.primary)),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(startup.description,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    if (startup.websiteUrl != null) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              launchUrl(Uri.parse(startup.websiteUrl!)),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Visit website'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Open opportunities',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 12),
                    oppsAsync.when(
                      loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                      data: (opps) {
                        final active = opps
                            .where((o) => o.isActive && !o.isExpired)
                            .toList();
                        if (active.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                                'No open opportunities right now. Check back soon.',
                                style:
                                    TextStyle(color: AppColors.textSecondary)),
                          );
                        }
                        return Column(
                          children: active
                              .map((o) => Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 10),
                                    child: _OpportunitySummaryCard(
                                      opportunity: o,
                                      isBookmarked: bookmarks.contains(o.id),
                                      onTap: () =>
                                          context.push('/opportunity/${o.id}'),
                                      onBookmark: () => ref
                                          .read(bookmarksProvider.notifier)
                                          .toggle(o.id),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
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
