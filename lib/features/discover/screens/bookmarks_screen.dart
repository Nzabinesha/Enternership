import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/widgets/opportunity_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final allOpps = ref.watch(opportunitiesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Saved opportunities')),
      body: allOpps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (opps) {
          final saved = opps.where((o) => bookmarks.contains(o.id)).toList();
          if (saved.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_border,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No saved opportunities',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'Bookmark opportunities to revisit them later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: saved.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OpportunityCard(
                opportunity: saved[i],
                isBookmarked: true,
                onTap: () => context.push('/opportunity/${saved[i].id}'),
                onBookmark: () =>
                    ref.read(bookmarksProvider.notifier).toggle(saved[i].id),
              ),
            ),
          );
        },
      ),
    );
  }
}
