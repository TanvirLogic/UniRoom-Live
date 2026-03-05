import 'package:cloud_firestore/cloud_firestore.dart';

class University {
  final String id;
  final String name;
  final String shortName;
  final String country;
  final List<String> departments;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.country,
    required this.departments,
  });

  factory University.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return University(
      id: doc.id,
      name: data['name'] ?? '',
      shortName: data['shortName'] ?? '',
      country: data['country'] ?? '',
      departments: List<String>.from(data['departments'] ?? []),
    );
  }
}
