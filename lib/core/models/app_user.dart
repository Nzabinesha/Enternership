import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, founder }

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final UserRole role;
  final String? bio;
  final List<String> skills;
  final String? cohort;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    required this.role,
    this.bio,
    this.skills = const [],
    this.cohort,
    this.linkedinUrl,
    this.portfolioUrl,
    required this.createdAt,
  });

  bool get isFounder => role == UserRole.founder;
  bool get isStudent => role == UserRole.student;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] == 'founder' ? UserRole.founder : UserRole.student,
      bio: data['bio'],
      skills: List<String>.from(data['skills'] ?? []),
      cohort: data['cohort'],
      linkedinUrl: data['linkedinUrl'],
      portfolioUrl: data['portfolioUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'role': role == UserRole.founder ? 'founder' : 'student',
      'bio': bio,
      'skills': skills,
      'cohort': cohort,
      'linkedinUrl': linkedinUrl,
      'portfolioUrl': portfolioUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? fullName,
    String? photoUrl,
    String? bio,
    List<String>? skills,
    String? cohort,
    String? linkedinUrl,
    String? portfolioUrl,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      cohort: cohort ?? this.cohort,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      createdAt: createdAt,
    );
  }
}
