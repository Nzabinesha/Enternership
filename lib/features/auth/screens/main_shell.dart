import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';

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
      path: '/admin',
      label: 'Admin',
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings
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
      path: '/admin',
      label: 'Admin',
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings
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
    final unreadCount = ref.watch(unreadNotificationCountProvider).value ?? 0;
    final tabs = user?.isFounder == true ? _founderTabs : _studentTabs;

    return Scaffold(
      // Notification bell - visible on all main screens
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'notif_fab',
        backgroundColor: AppColors.white,
        elevation: 2,
        onPressed: () => context.push('/notifications'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
