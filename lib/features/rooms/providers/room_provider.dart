import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/room_model.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream rooms with optional filters
  Stream<List<Room>> roomsStream({
    String? universityId,
    String? department,
    String? batch,
    String? courseName,
  }) {
    Query query = _firestore.collection('rooms');

    if (universityId != null && universityId.isNotEmpty) {
      query = query.where('universityId', isEqualTo: universityId);
    }
    if (department != null && department.isNotEmpty) {
      query = query.where('department', isEqualTo: department);
    }
    if (batch != null && batch.isNotEmpty) {
      query = query.where('batch', isEqualTo: batch);
    }
    if (courseName != null && courseName.isNotEmpty) {
      query = query.where('courseName', isEqualTo: courseName);
    }

    return query.snapshots().map(
          (snapshot) =>
          snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList(),
    );
  }

  /// Update room status (CR only)
  Future<void> updateRoomStatus({
    required String roomId,
    required String status,
    required String updatedBy, // pass current user id or name
  }) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'status': status,
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add a new room (CR only)
  Future<void> addRoom({
    required String roomNumber,
    required String universityId,
    required String department,
    required String batch,
    required String courseName,
    required String courseTeacher,
    required String createdBy, // current user id or name
  }) async {
    await _firestore.collection('rooms').add({
      'roomNumber': roomNumber,
      'universityId': universityId,
      'department': department,
      'batch': batch,
      'courseName': courseName,
      'courseTeacher': courseTeacher,
      'status': 'available',
      'updatedBy': createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}