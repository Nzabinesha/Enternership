import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/main_shell.dart';
import '../features/discover/screens/discover_screen.dart';
import '../features/discover/screens/opportunity_detail_screen.dart';
import '../features/discover/screens/bookmarks_screen.dart';
import '../features/startups/screens/startups_screen.dart';
import '../features/startups/screens/startup_detail_screen.dart';
import '../features/startups/screens/my_startup_screen.dart';
import '../features/startups/screens/create_startup_screen.dart';
import '../features/startups/screens/post_opportunity_screen.dart';
import '../features/applications/screens/my_applications_screen.dart';
import '../features/applications/screens/apply_screen.dart';
import '../features/applications/screens/applicants_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/discover',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/discover';
      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Discover tab
          GoRoute(
            path: '/discover',
            builder: (_, __) => const DiscoverScreen(),
          ),
          // Startups tab (student)
          GoRoute(
            path: '/startups',
            builder: (_, __) => const StartupsScreen(),
          ),
          // Applications tab (student)
          GoRoute(
            path: '/applications',
            builder: (_, __) => const MyApplicationsScreen(),
          ),
          // My Startup tab (founder)
          GoRoute(
            path: '/my-startup',
            builder: (_, __) => const MyStartupScreen(),
          ),
          // Applicants tab (founder)
          GoRoute(
            path: '/applicants',
            builder: (_, __) => const _PlaceholderApplicants(),
          ),
          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Full-screen routes (above shell)
      GoRoute(
        path: '/opportunity/:id',
        builder: (_, state) => OpportunityDetailScreen(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/apply/:id',
        builder: (_, state) => ApplyScreen(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/startup/:id',
        builder: (_, state) => StartupDetailScreen(startupId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/applicants/:id',
        builder: (_, state) => ApplicantsScreen(opportunityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/create-startup',
        builder: (_, __) => const CreateStartupScreen(),
      ),
      GoRoute(
        path: '/edit-startup/:id',
        builder: (_, state) => const CreateStartupScreen(), // reuse form for editing
      ),
      GoRoute(
        path: '/post-opportunity/:startupId',
        builder: (_, state) => PostOpportunityScreen(startupId: state.pathParameters['startupId']!),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (_, __) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (_, __) => const EditProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

// Placeholder for the founder's applicants tab (redirects to manage view)
class _PlaceholderApplicants extends ConsumerWidget {
  const _PlaceholderApplicants();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(myStartupProvider);
    return startupAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (startup) => Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(title: const Text('Applicants')),
        body: startup == null
            ? const Center(child: Text('Register your startup first.'))
            : Consumer(builder: (context, ref, _) {
                final oppsAsync = ref.watch(startupOpportunitiesProvider(startup.id));
                return oppsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (opps) {
                    if (opps.isEmpty) {
                      return const Center(child: Text('No opportunities posted yet.', style: TextStyle(color: Color(0xFF5A6788))));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: opps.length,
                      itemBuilder: (_, i) {
                        final o = opps[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(o.title),
                            subtitle: Text('${o.applicationCount} applicants'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => GoRouter.of(context).push('/applicants/${o.id}'),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
      ),
    );
  }
}
