import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // student | cr
  final String universityId;
  final String department;
  final String batch;
  final bool isApproved;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.universityId,
    required this.department,
    required this.batch,
    required this.isApproved,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      role: data['role'],
      universityId: data['universityId'],
      department: data['department'],
      batch: data['batch'],
      isApproved: data['isApproved'] ?? false,
    );
  }
}
