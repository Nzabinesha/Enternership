import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup.dart';

class StartupRepository {
  final FirebaseFirestore _db;
  StartupRepository(this._db);

  CollectionReference get _col => _db.collection('startups');

  Stream<List<Startup>> watchVerifiedStartups() {
    return _col
        .where('isVerified', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Startup.fromFirestore).toList());
  }

  Stream<List<Startup>> watchAllStartups() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Startup.fromFirestore).toList());
  }

  Stream<Startup?> watchMyStartup(String founderId) {
    return _col
        .where('founderId', isEqualTo: founderId)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : Startup.fromFirestore(s.docs.first));
  }

  Stream<Startup?> watchStartup(String id) {
    return _col.doc(id).snapshots().map((d) => d.exists ? Startup.fromFirestore(d) : null);
  }

  Future<String> createStartup(Startup startup) async {
    final doc = await _col.add(startup.toMap());
    return doc.id;
  }

  Future<void> updateStartup(Startup startup) async {
    await _col.doc(startup.id).update(startup.toMap());
  }
}
