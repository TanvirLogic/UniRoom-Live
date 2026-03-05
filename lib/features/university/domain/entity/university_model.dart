import 'package:cloud_firestore/cloud_firestore.dart';

class University {
  final String id;
  final String name;
  final String shortName;
  final String country;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.country,
  });

  factory University.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return University(
      id: doc.id,
      name: data['name'],
      shortName: data['shortName'],
      country: data['country'],
    );
  }
}