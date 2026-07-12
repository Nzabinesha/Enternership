import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/widgets/opportunity_card.dart';
import 'package:alu_enternership_pro/widgets/filter_sheet.dart';
import 'package:alu_enternership_pro/widgets/shimmer_loader.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opps = ref.watch(filteredOppsResultProvider);
    final filter = ref.watch(filteredOpportunitiesProvider);
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Find opportunities',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_outline,
                              color: Colors.white),
                          onPressed: () => context.push('/bookmarks'),
                          tooltip: 'Saved',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                height: 56,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                color: AppColors.primary,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => ref
                            .read(filteredOpportunitiesProvider.notifier)
                            .setQuery(v),
                        decoration: InputDecoration(
                          hintText: 'Search roles, skills, startups...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: filter.query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    ref
                                        .read(filteredOpportunitiesProvider
                                            .notifier)
                                        .setQuery('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryLight)),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: filter.hasActiveFilters
                                ? AppColors.accent
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.tune, color: Colors.white),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const FilterSheet(),
                            ),
                          ),
                        ),
                        if (filter.hasActiveFilters)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Active filter chips
          if (filter.hasActiveFilters)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Clear all',
                      icon: Icons.clear,
                      color: AppColors.accent,
                      onTap: () => ref
                          .read(filteredOpportunitiesProvider.notifier)
                          .clearAll(),
                    ),
                    if (filter.role != null) ...[
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: filter.role!,
                          onTap: () => ref
                              .read(filteredOpportunitiesProvider.notifier)
                              .setRole(null)),
                    ],
                    if (filter.isPaidOnly) ...[
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Paid',
                          onTap: () => ref
                              .read(filteredOpportunitiesProvider.notifier)
                              .togglePaid()),
                    ],
                    if (filter.isRemoteOnly) ...[
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Remote',
                          onTap: () => ref
                              .read(filteredOpportunitiesProvider.notifier)
                              .toggleRemote()),
                    ],
                    ...filter.skills.map((s) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                              label: s,
                              onTap: () => ref
                                  .read(filteredOpportunitiesProvider.notifier)
                                  .toggleSkill(s)),
                        )),
                  ],
                ),
              ),
            ),
          opps.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerCard()),
                  childCount: 5,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Could not load opportunities. $e')),
            ),
            data: (list) => list.isEmpty
                ? SliverFillRemaining(
                    child: _EmptyState(
                        hasFilter:
                            filter.hasActiveFilters || filter.query.isNotEmpty),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OpportunityCard(
                            opportunity: list[i],
                            isBookmarked: bookmarks.contains(list[i].id),
                            onTap: () =>
                                context.push('/opportunity/${list[i].id}'),
                            onBookmark: () => ref
                                .read(bookmarksProvider.notifier)
                                .toggle(list[i].id),
                          ),
                        ),
                        childCount: list.length,
                      ),
                    ),
                  ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: c),
              const SizedBox(width: 4)
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: c, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.close, size: 14, color: c),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hasFilter ? Icons.search_off : Icons.explore_outlined,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No matches found' : 'No opportunities yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try adjusting your filters or search terms.'
                  : 'Check back soon — startups are just getting started.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
