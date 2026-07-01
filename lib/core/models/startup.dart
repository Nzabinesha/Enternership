import 'package:cloud_firestore/cloud_firestore.dart';

class Startup {
  final String id;
  final String founderId;
  final String name;
  final String tagline;
  final String description;
  final String industry;
  final String? logoUrl;
  final String? websiteUrl;
  final bool isVerified;
  final String? aluCohort;
  final String? aluRegistrationId;
  final List<String> teamSize;
  final DateTime createdAt;
  final int opportunityCount;

  const Startup({
    required this.id,
    required this.founderId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.industry,
    this.logoUrl,
    this.websiteUrl,
    this.isVerified = false,
    this.aluCohort,
    this.aluRegistrationId,
    this.teamSize = const [],
    required this.createdAt,
    this.opportunityCount = 0,
  });

  factory Startup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Startup(
      id: doc.id,
      founderId: data['founderId'] ?? '',
      name: data['name'] ?? '',
      tagline: data['tagline'] ?? '',
      description: data['description'] ?? '',
      industry: data['industry'] ?? '',
      logoUrl: data['logoUrl'],
      websiteUrl: data['websiteUrl'],
      isVerified: data['isVerified'] ?? false,
      aluCohort: data['aluCohort'],
      aluRegistrationId: data['aluRegistrationId'],
      teamSize: List<String>.from(data['teamSize'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      opportunityCount: data['opportunityCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'founderId': founderId,
      'name': name,
      'tagline': tagline,
      'description': description,
      'industry': industry,
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'isVerified': isVerified,
      'aluCohort': aluCohort,
      'aluRegistrationId': aluRegistrationId,
      'teamSize': teamSize,
      'createdAt': Timestamp.fromDate(createdAt),
      'opportunityCount': opportunityCount,
    };
  }

  static const List<String> industries = [
    'EdTech',
    'FinTech',
    'HealthTech',
    'AgriTech',
    'E-Commerce',
    'SaaS',
    'CleanTech',
    'Logistics',
    'Media & Content',
    'Social Impact',
    'Other',
  ];
}
