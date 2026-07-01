import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/../core/theme/app_theme.dart';
import '/../providers/providers.dart';
import '/../core/models/startup.dart';
import '/../widgets/startup_avatar.dart';
import '/../widgets/shimmer_loader.dart';

class StartupsScreen extends ConsumerWidget {
  const StartupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupsAsync = ref.watch(startupsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Startups')),
      body: startupsAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerCard(height: 100)),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (startups) {
          if (startups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business_outlined,
                      size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text('No verified startups yet',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // Group by industry
          final byIndustry = <String, List<Startup>>{};
          for (final s in startups) {
            byIndustry.putIfAbsent(s.industry, () => []).add(s);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Featured startups (most opportunities)
              if (startups.length >= 3) ...[
                Text('Most active',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: startups.take(5).length,
                    itemBuilder: (_, i) => _FeaturedCard(startup: startups[i]),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // All startups
              Text('All startups (${startups.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...startups.map((s) => _StartupListTile(startup: s)),
            ],
          );
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Startup startup;
  const _FeaturedCard({required this.startup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/startup/${startup.id}'),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StartupAvatar(
                    name: startup.name, logoUrl: startup.logoUrl, size: 32),
                const Spacer(),
                if (startup.isVerified)
                  const Icon(Icons.verified,
                      size: 16, color: AppColors.primary),
              ],
            ),
            const Spacer(),
            Text(startup.name,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${startup.opportunityCount} open',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _StartupListTile extends StatelessWidget {
  final Startup startup;
  const _StartupListTile({required this.startup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/startup/${startup.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            StartupAvatar(
                name: startup.name, logoUrl: startup.logoUrl, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(startup.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (startup.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified,
                              size: 16, color: AppColors.primary),
                        ),
                    ],
                  ),
                  Text(startup.tagline,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(label: startup.industry),
                      const SizedBox(width: 8),
                      Text('${startup.opportunityCount} open',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500)),
    );
  }
}
