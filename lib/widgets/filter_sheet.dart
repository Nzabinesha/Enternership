import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/models/opportunity.dart';
import '../providers/providers.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filteredOpportunitiesProvider);
    final notifier = ref.read(filteredOpportunitiesProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Filter opportunities',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              if (filter.hasActiveFilters)
                TextButton(
                    onPressed: () {
                      notifier.clearAll();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear all')),
            ],
          ),
          const SizedBox(height: 20),

          // Type
          Text('Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OpportunityType.values.map((t) {
              final labels = {
                OpportunityType.internship: 'Internship',
                OpportunityType.partTime: 'Part-time',
                OpportunityType.project: 'Project',
                OpportunityType.volunteer: 'Volunteer',
              };
              final selected = filter.type == t;
              return FilterChip(
                label: Text(labels[t]!),
                selected: selected,
                onSelected: (_) => notifier.setType(selected ? null : t),
                selectedColor: AppColors.primary.withOpacity(0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
                side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Role
          Text('Role', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Software Developer',
              'UI/UX Designer',
              'Marketing',
              'Data & Research',
              'Operations',
              'Content Creator'
            ].map((r) {
              final selected = filter.role == r;
              return FilterChip(
                label: Text(r),
                selected: selected,
                onSelected: (_) => notifier.setRole(selected ? null : r),
                selectedColor: AppColors.primary.withOpacity(0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
                side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Toggles
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _Toggle(
              label: 'Paid only',
              value: filter.isPaidOnly,
              onChanged: (_) => notifier.togglePaid()),
          _Toggle(
              label: 'Remote only',
              value: filter.isRemoteOnly,
              onChanged: (_) => notifier.toggleRemote()),
          const SizedBox(height: 20),

          // Skills
          Text('Skills', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter',
              'Python',
              'Figma',
              'React',
              'Marketing',
              'Finance',
              'Research',
              'SQL'
            ].map((s) {
              final selected = filter.skills.contains(s);
              return FilterChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => notifier.toggleSkill(s),
                selectedColor: AppColors.primary.withOpacity(0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary),
                side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary),
      ],
    );
  }
}
