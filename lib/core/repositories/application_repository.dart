import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';

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
    await _db.collection('opportunities').doc(app.opportunityId).update({
      'applicationCount': FieldValue.increment(1),
    });
  }

  Future<void> updateStatus(String appId, ApplicationStatus status, {String? note}) async {
    await _col.doc(appId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
      if (note != null) 'founderNote': note,
    });
  }

  Future<void> withdrawApplication(String appId, String opportunityId) async {
    await _col.doc(appId).delete();
    await _db.collection('opportunities').doc(opportunityId).update({
      'applicationCount': FieldValue.increment(-1),
    });
  }
}
