import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/opportunity.dart';
import '../core/theme/app_theme.dart';
import 'startup_avatar.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                StartupAvatar(name: o.startupName, logoUrl: o.startupLogoUrl, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(o.startupName,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (o.startupVerified)
                            const Icon(Icons.verified, size: 14, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(o.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onBookmark,
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.primary : AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Tag(label: o.typeLabel, color: AppColors.primary),
                _Tag(label: o.role, color: AppColors.textSecondary),
                if (o.isRemote) _Tag(label: 'Remote', color: AppColors.success),
                if (o.isPaid) _Tag(label: 'Paid', color: AppColors.accent),
              ],
            ),
            const SizedBox(height: 10),
            if (o.requiredSkills.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: o.requiredSkills.take(4).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                )).toList(),
              ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(o.duration, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const Spacer(),
                Icon(
                  Icons.event_outlined,
                  size: 13,
                  color: o.isExpired ? AppColors.accent : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  o.isExpired ? 'Expired' : 'Due ${DateFormat('MMM d').format(o.deadline)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: o.isExpired ? AppColors.accent : AppColors.textMuted,
                    fontWeight: o.isExpired ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
