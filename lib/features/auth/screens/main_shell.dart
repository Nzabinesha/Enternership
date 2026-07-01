import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/widgets/alu_logo.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<({String path, String label, IconData icon, IconData activeIcon})>
      _studentTabs = const [
    (
      path: '/discover',
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore
    ),
    (
      path: '/startups',
      label: 'Startups',
      icon: Icons.business_outlined,
      activeIcon: Icons.business
    ),
    (
      path: '/applications',
      label: 'My Apps',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment
    ),
    (
      path: '/profile',
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person
    ),
  ];

  final List<({String path, String label, IconData icon, IconData activeIcon})>
      _founderTabs = const [
    (
      path: '/discover',
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore
    ),
    (
      path: '/my-startup',
      label: 'My Startup',
      icon: Icons.rocket_launch_outlined,
      activeIcon: Icons.rocket_launch
    ),
    (
      path: '/applicants',
      label: 'Applicants',
      icon: Icons.people_outline,
      activeIcon: Icons.people
    ),
    (
      path: '/profile',
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final tabs = user?.isFounder == true ? _founderTabs : _studentTabs;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.divider)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: tabs.asMap().entries.map((e) {
                final idx = e.key;
                final tab = e.value;
                final selected = _currentIndex == idx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _currentIndex = idx);
                      context.go(tab.path);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? tab.activeIcon : tab.icon,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
