import 'package:cloud_firestore/cloud_firestore.dart';

enum OpportunityType { internship, partTime, project, volunteer }

class Opportunity {
  final String id;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final bool startupVerified;
  final String title;
  final String description;
  final String role;
  final OpportunityType type;
  final List<String> requiredSkills;
  final String duration;
  final bool isPaid;
  final String? compensation;
  final bool isRemote;
  final String? location;
  final DateTime deadline;
  final DateTime createdAt;
  final bool isActive;
  final int applicationCount;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    this.startupLogoUrl,
    this.startupVerified = false,
    required this.title,
    required this.description,
    required this.role,
    required this.type,
    this.requiredSkills = const [],
    required this.duration,
    this.isPaid = false,
    this.compensation,
    this.isRemote = false,
    this.location,
    required this.deadline,
    required this.createdAt,
    this.isActive = true,
    this.applicationCount = 0,
  });

  bool get isExpired => deadline.isBefore(DateTime.now());

  factory Opportunity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Opportunity(
      id: doc.id,
      startupId: data['startupId'] ?? '',
      startupName: data['startupName'] ?? '',
      startupLogoUrl: data['startupLogoUrl'],
      startupVerified: data['startupVerified'] ?? false,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      role: data['role'] ?? '',
      type: _parseType(data['type']),
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      duration: data['duration'] ?? '',
      isPaid: data['isPaid'] ?? false,
      compensation: data['compensation'],
      isRemote: data['isRemote'] ?? false,
      location: data['location'],
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      applicationCount: data['applicationCount'] ?? 0,
    );
  }

  static OpportunityType _parseType(String? t) {
    switch (t) {
      case 'partTime': return OpportunityType.partTime;
      case 'project': return OpportunityType.project;
      case 'volunteer': return OpportunityType.volunteer;
      default: return OpportunityType.internship;
    }
  }

  String get typeLabel {
    switch (type) {
      case OpportunityType.internship: return 'Internship';
      case OpportunityType.partTime: return 'Part-time';
      case OpportunityType.project: return 'Project';
      case OpportunityType.volunteer: return 'Volunteer';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'startupLogoUrl': startupLogoUrl,
      'startupVerified': startupVerified,
      'title': title,
      'description': description,
      'role': role,
      'type': type.name,
      'requiredSkills': requiredSkills,
      'duration': duration,
      'isPaid': isPaid,
      'compensation': compensation,
      'isRemote': isRemote,
      'location': location,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'applicationCount': applicationCount,
    };
  }

  static const List<String> roles = [
    'Software Developer',
    'UI/UX Designer',
    'Product Manager',
    'Marketing',
    'Business Analysis',
    'Data & Research',
    'Operations',
    'Content Creator',
    'Community Manager',
    'Finance',
    'Other',
  ];

  static const List<String> skills = [
    'Flutter', 'React', 'Python', 'Node.js', 'Figma', 'SQL',
    'Firebase', 'Marketing', 'Excel', 'Communication', 'Research',
    'Content Writing', 'Video Editing', 'Graphic Design', 'Leadership',
    'Finance', 'Data Analysis', 'Java', 'Swift', 'TypeScript',
  ];
}
