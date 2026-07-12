import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/app_user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not signed in')));
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                expandedHeight: 200,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/edit-profile'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _confirmSignOut(context, ref),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _Avatar(user: user),
                        const SizedBox(height: 10),
                        Text(user.fullName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        Text(user.email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Role badge
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.isFounder
                                  ? AppColors.accent.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.isFounder ? 'Startup Founder' : 'Student',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: user.isFounder
                                    ? AppColors.accent
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          if (user.cohort != null) ...[
                            const SizedBox(width: 10),
                            Text(user.cohort!,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bio
                    if (user.bio != null && user.bio!.isNotEmpty)
                      _Section(
                        title: 'About',
                        child: Text(user.bio!,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    // Skills
                    if (user.skills.isNotEmpty)
                      _Section(
                        title: 'Skills',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.skills
                              .map((s) => Chip(
                                    label: Text(s),
                                    backgroundColor: AppColors.surfaceVariant,
                                    side: BorderSide.none,
                                  ))
                              .toList(),
                        ),
                      ),
                    // Links
                    if (user.linkedinUrl != null || user.portfolioUrl != null)
                      _Section(
                        title: 'Links',
                        child: Column(
                          children: [
                            if (user.linkedinUrl != null)
                              _LinkTile(
                                  label: 'LinkedIn',
                                  url: user.linkedinUrl!,
                                  icon: Icons.link),
                            if (user.portfolioUrl != null)
                              _LinkTile(
                                  label: 'Portfolio',
                                  url: user.portfolioUrl!,
                                  icon: Icons.web_outlined),
                          ],
                        ),
                      ),
                    // Empty state prompt
                    if (user.bio == null && user.skills.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.15)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.person_outline,
                                color: AppColors.primary, size: 32),
                            const SizedBox(height: 8),
                            Text('Complete your profile',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            const Text(
                              'Add your bio, skills, and links to stand out to startups.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.push('/edit-profile'),
                              child: const Text('Complete profile'),
                            ),
                          ],
                        ),
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

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(authRepositoryProvider).signOut();
            },
            child: const Text('Sign out',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppUser user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl != null) {
      return CircleAvatar(
          radius: 36, backgroundImage: NetworkImage(user.photoUrl!));
    }
    final initials = user.fullName
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return CircleAvatar(
      radius: 36,
      backgroundColor: Colors.white.withOpacity(0.2),
      child: Text(initials,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
    );
  }
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String label;
  final String url;
  final IconData icon;
  const _LinkTile({required this.label, required this.url, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(url,
                  style:
                      const TextStyle(color: AppColors.primary, fontSize: 12),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
