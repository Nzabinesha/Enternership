import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/app_user.dart';
import '../core/models/startup.dart';
import '../core/models/opportunity.dart';
import '../core/models/application.dart';
import '../core/models/notification.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/startup_repository.dart';
import '../core/repositories/opportunity_repository.dart';
import '../core/repositories/application_repository.dart';
import '../core/repositories/notification_repository.dart';

// ─── Firebase Instances ───────────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ─── Repositories ─────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository(ref.watch(firestoreProvider));
});

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(ref.watch(firestoreProvider));
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(ref.watch(firestoreProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(firestoreProvider));
});

// ─── Auth State ───────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref
          .watch(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Startups ─────────────────────────────────────────────────────────────────

final startupsStreamProvider = StreamProvider<List<Startup>>((ref) {
  return ref.watch(startupRepositoryProvider).watchVerifiedStartups();
});

// Watches ALL startups (verified + unverified) — used by admin dashboard
final allStartupsStreamProvider = StreamProvider<List<Startup>>((ref) {
  return ref.watch(startupRepositoryProvider).watchAllStartups();
});

final myStartupProvider = StreamProvider<Startup?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(startupRepositoryProvider).watchMyStartup(user.uid);
});

final startupByIdProvider = StreamProvider.family<Startup?, String>((ref, id) {
  return ref.watch(startupRepositoryProvider).watchStartup(id);
});

// ─── Opportunities ────────────────────────────────────────────────────────────

final opportunitiesStreamProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchActiveOpportunities();
});

final filteredOpportunitiesProvider =
    StateNotifierProvider<OpportunityFilterNotifier, OpportunityFilter>((ref) {
  return OpportunityFilterNotifier();
});

final filteredOppsResultProvider =
    Provider<AsyncValue<List<Opportunity>>>((ref) {
  final all = ref.watch(opportunitiesStreamProvider);
  final filter = ref.watch(filteredOpportunitiesProvider);

  return all.whenData((opps) {
    var result = opps;
    if (filter.query.isNotEmpty) {
      final q = filter.query.toLowerCase();
      result = result
          .where((o) =>
              o.title.toLowerCase().contains(q) ||
              o.startupName.toLowerCase().contains(q) ||
              o.role.toLowerCase().contains(q) ||
              o.requiredSkills.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }
    if (filter.role != null) {
      result = result.where((o) => o.role == filter.role).toList();
    }
    if (filter.type != null) {
      result = result.where((o) => o.type == filter.type).toList();
    }
    if (filter.isPaidOnly) {
      result = result.where((o) => o.isPaid).toList();
    }
    if (filter.isRemoteOnly) {
      result = result.where((o) => o.isRemote).toList();
    }
    if (filter.skills.isNotEmpty) {
      result = result
          .where((o) => filter.skills.any((s) => o.requiredSkills.contains(s)))
          .toList();
    }
    return result;
  });
});

// Skill-matched opportunities — shows opps that match the student's own skills
final skillMatchedOppsProvider = Provider<AsyncValue<List<Opportunity>>>((ref) {
  final all = ref.watch(opportunitiesStreamProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.skills.isEmpty) return const AsyncValue.data([]);
  return all.whenData((opps) => opps
      .where((o) => o.requiredSkills.any((s) => user.skills.contains(s)))
      .take(5)
      .toList());
});

final opportunityByIdProvider =
    StreamProvider.family<Opportunity?, String>((ref, id) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunity(id);
});

final startupOpportunitiesProvider =
    StreamProvider.family<List<Opportunity>, String>((ref, startupId) {
  return ref
      .watch(opportunityRepositoryProvider)
      .watchStartupOpportunities(startupId);
});

// ─── Applications ─────────────────────────────────────────────────────────────

final myApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(applicationRepositoryProvider)
      .watchStudentApplications(user.uid);
});

final startupApplicationsProvider =
    StreamProvider.family<List<Application>, String>((ref, opportunityId) {
  return ref
      .watch(applicationRepositoryProvider)
      .watchOpportunityApplications(opportunityId);
});

final hasAppliedProvider =
    FutureProvider.family<bool, ({String studentId, String opportunityId})>(
        (ref, args) {
  return ref
      .watch(applicationRepositoryProvider)
      .hasApplied(args.studentId, args.opportunityId);
});

// ─── Notifications ────────────────────────────────────────────────────────────

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(notificationRepositoryProvider).watchNotifications(user.uid);
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(user.uid);
});

// ─── Bookmarks ────────────────────────────────────────────────────────────────

final bookmarksProvider =
    StateNotifierProvider<BookmarkNotifier, Set<String>>((ref) {
  return BookmarkNotifier();
});

// ─── Filter State ─────────────────────────────────────────────────────────────

class OpportunityFilter {
  final String query;
  final String? role;
  final OpportunityType? type;
  final bool isPaidOnly;
  final bool isRemoteOnly;
  final List<String> skills;

  const OpportunityFilter({
    this.query = '',
    this.role,
    this.type,
    this.isPaidOnly = false,
    this.isRemoteOnly = false,
    this.skills = const [],
  });

  OpportunityFilter copyWith({
    String? query,
    String? role,
    OpportunityType? type,
    bool? isPaidOnly,
    bool? isRemoteOnly,
    List<String>? skills,
    bool clearRole = false,
    bool clearType = false,
  }) {
    return OpportunityFilter(
      query: query ?? this.query,
      role: clearRole ? null : (role ?? this.role),
      type: clearType ? null : (type ?? this.type),
      isPaidOnly: isPaidOnly ?? this.isPaidOnly,
      isRemoteOnly: isRemoteOnly ?? this.isRemoteOnly,
      skills: skills ?? this.skills,
    );
  }

  bool get hasActiveFilters =>
      role != null ||
      type != null ||
      isPaidOnly ||
      isRemoteOnly ||
      skills.isNotEmpty;
}

class OpportunityFilterNotifier extends StateNotifier<OpportunityFilter> {
  OpportunityFilterNotifier() : super(const OpportunityFilter());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setRole(String? r) => r == null
      ? state = state.copyWith(clearRole: true)
      : state = state.copyWith(role: r);
  void setType(OpportunityType? t) => t == null
      ? state = state.copyWith(clearType: true)
      : state = state.copyWith(type: t);
  void togglePaid() => state = state.copyWith(isPaidOnly: !state.isPaidOnly);
  void toggleRemote() =>
      state = state.copyWith(isRemoteOnly: !state.isRemoteOnly);
  void toggleSkill(String skill) {
    final skills = List<String>.from(state.skills);
    skills.contains(skill) ? skills.remove(skill) : skills.add(skill);
    state = state.copyWith(skills: skills);
  }

  void clearAll() => state = const OpportunityFilter();
}

class BookmarkNotifier extends StateNotifier<Set<String>> {
  BookmarkNotifier() : super({});

  void toggle(String opportunityId) {
    final current = Set<String>.from(state);
    current.contains(opportunityId)
        ? current.remove(opportunityId)
        : current.add(opportunityId);
    state = current;
  }

  bool isBookmarked(String id) => state.contains(id);
}
