import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  applicationReceived,
  statusUpdated,
  startupVerified,
  opportunityDeadline,
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? actionId; // opportunityId or applicationId to navigate to

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.actionId,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      type: _parseType(d['type']),
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actionId: d['actionId'],
    );
  }

  static NotificationType _parseType(String? t) {
    switch (t) {
      case 'applicationReceived': return NotificationType.applicationReceived;
      case 'statusUpdated': return NotificationType.statusUpdated;
      case 'startupVerified': return NotificationType.startupVerified;
      case 'opportunityDeadline': return NotificationType.opportunityDeadline;
      default: return NotificationType.statusUpdated;
    }
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'body': body,
    'type': type.name,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
    'actionId': actionId,
  };
}
