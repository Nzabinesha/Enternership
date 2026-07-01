import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityRepository {
  final FirebaseFirestore _db;
  OpportunityRepository(this._db);

  CollectionReference get _col => _db.collection('opportunities');

  Stream<List<Opportunity>> watchActiveOpportunities() {
    return _col
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Opportunity.fromFirestore).toList());
  }

  Stream<Opportunity?> watchOpportunity(String id) {
    return _col.doc(id).snapshots()
        .map((d) => d.exists ? Opportunity.fromFirestore(d) : null);
  }

  Stream<List<Opportunity>> watchStartupOpportunities(String startupId) {
    return _col
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Opportunity.fromFirestore).toList());
  }

  Future<String> createOpportunity(Opportunity opp) async {
    final doc = await _col.add(opp.toMap());
    // Increment startup opportunity count
    await _db.collection('startups').doc(opp.startupId).update({
      'opportunityCount': FieldValue.increment(1),
    });
    return doc.id;
  }

  Future<void> updateOpportunity(Opportunity opp) async {
    await _col.doc(opp.id).update(opp.toMap());
  }

  Future<void> closeOpportunity(String id) async {
    await _col.doc(id).update({'isActive': false});
  }
}
