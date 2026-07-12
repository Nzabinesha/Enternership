import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/startup.dart';
import 'package:alu_enternership_pro/core/models/notification.dart';
import 'package:alu_enternership_pro/widgets/startup_avatar.dart';
import 'package:intl/intl.dart';

// Simple admin PIN — in production this would be a server-side role check
const _adminPin = '2026ALU';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _authenticated = false;
  final _pinCtrl = TextEditingController();
  String? _pinError;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  void _authenticate() {
    if (_pinCtrl.text.trim() == _adminPin) {
      setState(() {
        _authenticated = true;
        _pinError = null;
      });
    } else {
      setState(() => _pinError = 'Incorrect admin PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return _PinGate(
        controller: _pinCtrl,
        error: _pinError,
        onSubmit: _authenticate,
      );
    }

    return _AdminContent();
  }
}

// ── PIN gate ──────────────────────────────────────────────────────────────────

class _PinGate extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback onSubmit;

  const _PinGate({
    required this.controller,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Admin Access')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings_outlined,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text('Admin Dashboard',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Enter your admin PIN to continue.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: controller,
              obscureText: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                labelText: 'Admin PIN',
                prefixIcon: const Icon(Icons.lock_outline),
                errorText: error,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: const Text('Enter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main admin content ────────────────────────────────────────────────────────

class _AdminContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStartups = ref.watch(allStartupsStreamProvider);
    final allOpps = ref.watch(opportunitiesStreamProvider);
    final allApps = ref.watch(myApplicationsProvider); // reuse for count

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: allStartups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (startups) {
          final pending = startups.where((s) => !s.isVerified).toList();
          final verified = startups.where((s) => s.isVerified).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Platform stats row
              Row(
                children: [
                  _StatCard(
                    label: 'Total startups',
                    value: '${startups.length}',
                    icon: Icons.business_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Verified',
                    value: '${verified.length}',
                    icon: Icons.verified_outlined,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Pending',
                    value: '${pending.length}',
                    icon: Icons.hourglass_empty,
                    color: AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pending verification
              if (pending.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.pending_actions,
                        size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text('Pending verification (${pending.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                ...pending.map((s) => _StartupReviewCard(
                      startup: s,
                      isPending: true,
                    )),
                const SizedBox(height: 24),
              ],

              // Verified startups
              Row(
                children: [
                  const Icon(Icons.verified,
                      size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text('Verified startups (${verified.length})',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              if (verified.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('No verified startups yet.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ...verified.map((s) => _StartupReviewCard(
                    startup: s,
                    isPending: false,
                  )),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

// ── Startup review card ───────────────────────────────────────────────────────

class _StartupReviewCard extends ConsumerWidget {
  final Startup startup;
  final bool isPending;

  const _StartupReviewCard({
    required this.startup,
    required this.isPending,
  });

  Future<void> _verify(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify startup'),
        content: Text(
            'Approve "${startup.name}" as an ALU-recognised startup? They will be able to post opportunities immediately.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Verify')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      // Update isVerified in Firestore
      await ref
          .read(firestoreProvider)
          .collection('startups')
          .doc(startup.id)
          .update({'isVerified': true});

      // Send in-app notification to the founder
      final notification = AppNotification(
        id: '',
        userId: startup.founderId,
        title: 'Startup verified! 🎉',
        body:
            '${startup.name} has been verified by ALU. You can now post opportunities.',
        type: NotificationType.startupVerified,
        createdAt: DateTime.now(),
        actionId: startup.id,
      );
      await ref
          .read(notificationRepositoryProvider)
          .createNotification(notification);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${startup.name} verified successfully!'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke verification'),
        content: Text(
            'Remove ALU verification from "${startup.name}"? They will no longer be able to post opportunities.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Revoke',
                  style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref
          .read(firestoreProvider)
          .collection('startups')
          .doc(startup.id)
          .update({'isVerified': false});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verification revoked.'),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending
              ? AppColors.warning.withOpacity(0.4)
              : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StartupAvatar(
                  name: startup.name, logoUrl: startup.logoUrl, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startup.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(startup.industry,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPending ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(startup.tagline,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          if (startup.aluCohort != null ||
              startup.aluRegistrationId != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (startup.aluCohort != null)
                  _InfoChip(
                      icon: Icons.school_outlined, label: startup.aluCohort!),
                if (startup.aluRegistrationId != null)
                  _InfoChip(
                      icon: Icons.badge_outlined,
                      label: 'ID: ${startup.aluRegistrationId!}'),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Registered: ${DateFormat('MMM d, y').format(startup.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isPending)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verify(context, ref),
                    icon: const Icon(Icons.verified_outlined, size: 16),
                    label: const Text('Verify startup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _revoke(context, ref),
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    label: const Text('Revoke'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
