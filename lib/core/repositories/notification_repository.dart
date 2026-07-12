import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class NotificationRepository {
  final FirebaseFirestore _db;
  NotificationRepository(this._db);

  CollectionReference get _col => _db.collection('notifications');

  // Stream of notifications for the current user, newest first
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(AppNotification.fromFirestore).toList());
  }

  // Count of unread notifications (used for badge)
  Stream<int> watchUnreadCount(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<void> markAsRead(String notificationId) async {
    await _col.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> createNotification(AppNotification notification) async {
    await _col.add(notification.toMap());
  }

  Future<void> deleteNotification(String id) async {
    await _col.doc(id).delete();
  }
}
