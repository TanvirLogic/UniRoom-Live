import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/room_model.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream rooms filtered by university and department
  Stream<List<Room>> roomsStream({
    required String universityId,
    required String department,
  }) {
    return _firestore
        .collection('rooms')
        .where('universityId', isEqualTo: universityId)
        .where('department', isEqualTo: department)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
  }

  /// Stream all rooms (for CRs)
  Stream<List<Room>> allRoomsStream({
    required String universityId,
  }) {
    return _firestore
        .collection('rooms')
        .where('universityId', isEqualTo: universityId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
  }

  /// Update room status
  Future<void> updateRoomStatus({
    required String roomId,
    required String status,
    required String updatedBy,
    required String department, // ✅ CR can reassign department
  }) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'status': status,
      'department': department, // reassign ownership
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add a new room
  Future<void> addRoom({
    required String roomNumber,
    required String universityId,
    required String department,
    required String batch,
    required String courseName,
    required String courseTeacher,
    required String createdBy,
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

  /// Update room details (CR edit → can change department)
  Future<void> updateRoomDetails({
    required String roomId,
    required String roomNumber,
    required String batch,
    required String courseName,
    required String courseTeacher,
    required String updatedBy,
    required String department,
  }) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'roomNumber': roomNumber,
      'batch': batch,
      'courseName': courseName,
      'courseTeacher': courseTeacher,
      'department': department, // ✅ reassign department
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a room
  Future<void> deleteRoom(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).delete();
  }
}