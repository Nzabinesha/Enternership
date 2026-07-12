import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';
import '../models/notification.dart';

class ApplicationRepository {
  final FirebaseFirestore _db;
  ApplicationRepository(this._db);

  CollectionReference get _col => _db.collection('applications');

  Stream<List<Application>> watchStudentApplications(String studentId) {
    return _col
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Application.fromFirestore).toList());
  }

  Stream<List<Application>> watchOpportunityApplications(String opportunityId) {
    return _col
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Application.fromFirestore).toList());
  }

  Future<bool> hasApplied(String studentId, String opportunityId) async {
    final q = await _col
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  Future<void> submitApplication(Application app) async {
    await _col.add(app.toMap());
    // Increment application count on the opportunity
    await _db
        .collection('opportunities')
        .doc(app.opportunityId)
        .update({'applicationCount': FieldValue.increment(1)});

    // Notify the startup founder
    final notif = AppNotification(
      id: '',
      userId: '', // will be set to founderId by looking up startup
      title: 'New application received',
      body:
          '${app.studentName} applied for "${app.opportunityTitle}" at ${app.startupName}.',
      type: NotificationType.applicationReceived,
      createdAt: DateTime.now(),
      actionId: app.opportunityId,
    );
    // Get the founder's userId from the startup document
    final startupDoc =
        await _db.collection('startups').doc(app.startupId).get();
    if (startupDoc.exists) {
      final founderId =
          (startupDoc.data() as Map<String, dynamic>)['founderId'] as String?;
      if (founderId != null) {
        await _db.collection('notifications').add(
              notif.toMap()..['userId'] = founderId,
            );
      }
    }
  }

  // Update application status and notify the student
  Future<void> updateStatus(
    String appId,
    ApplicationStatus status, {
    String? note,
    required String studentId,
    required String opportunityTitle,
    required String startupName,
  }) async {
    await _col.doc(appId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
      if (note != null) 'founderNote': note,
    });

    // Send in-app notification to the student
    final statusLabel = _statusLabel(status);
    final notif = AppNotification(
      id: '',
      userId: studentId,
      title: 'Application update: $statusLabel',
      body:
          'Your application for "$opportunityTitle" at $startupName has been updated to $statusLabel.',
      type: NotificationType.statusUpdated,
      createdAt: DateTime.now(),
      actionId: appId,
    );
    await _db.collection('notifications').add(notif.toMap());
  }

  // Withdraw (delete) an application — completes CRUD with Delete
  Future<void> withdrawApplication(String appId, String opportunityId) async {
    await _col.doc(appId).delete();
    await _db
        .collection('opportunities')
        .doc(opportunityId)
        .update({'applicationCount': FieldValue.increment(-1)});
  }

  String _statusLabel(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.reviewed:
        return 'Under Review';
      case ApplicationStatus.interview:
        return 'Interview Stage';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Not Selected';
    }
  }
}
