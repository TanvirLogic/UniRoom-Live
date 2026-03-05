import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entity/university_model.dart';

class UniversityProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<University> _universities = [];
  List<University> get universities => _universities;

  Future<void> fetchUniversities() async {
    final snapshot = await _firestore.collection('universities').get();
    _universities = snapshot.docs.map((doc) => University.fromFirestore(doc)).toList();
    notifyListeners();
  }
  Future<University?> getUniversityById(String id) async {
    final doc = await _firestore.collection('universities').doc(id).get();
    if (!doc.exists) return null;
    return University.fromFirestore(doc);
  }
}

