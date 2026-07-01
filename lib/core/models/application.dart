import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { applied, reviewed, interview, accepted, rejected }

class Application {
  final String id;
  final String studentId;
  final String studentName;
  final String? studentPhotoUrl;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String coverLetter;
  final String? portfolioUrl;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? founderNote;

  const Application({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentPhotoUrl,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.coverLetter,
    this.portfolioUrl,
    this.status = ApplicationStatus.applied,
    required this.appliedAt,
    this.updatedAt,
    this.founderNote,
  });

  String get statusLabel {
    switch (status) {
      case ApplicationStatus.applied: return 'Applied';
      case ApplicationStatus.reviewed: return 'Under Review';
      case ApplicationStatus.interview: return 'Interview';
      case ApplicationStatus.accepted: return 'Accepted';
      case ApplicationStatus.rejected: return 'Not Selected';
    }
  }

  factory Application.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Application(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentPhotoUrl: data['studentPhotoUrl'],
      opportunityId: data['opportunityId'] ?? '',
      opportunityTitle: data['opportunityTitle'] ?? '',
      startupId: data['startupId'] ?? '',
      startupName: data['startupName'] ?? '',
      coverLetter: data['coverLetter'] ?? '',
      portfolioUrl: data['portfolioUrl'],
      status: _parseStatus(data['status']),
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      founderNote: data['founderNote'],
    );
  }

  static ApplicationStatus _parseStatus(String? s) {
    switch (s) {
      case 'reviewed': return ApplicationStatus.reviewed;
      case 'interview': return ApplicationStatus.interview;
      case 'accepted': return ApplicationStatus.accepted;
      case 'rejected': return ApplicationStatus.rejected;
      default: return ApplicationStatus.applied;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentPhotoUrl': studentPhotoUrl,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'coverLetter': coverLetter,
      'portfolioUrl': portfolioUrl,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'founderNote': founderNote,
    };
  }
}
