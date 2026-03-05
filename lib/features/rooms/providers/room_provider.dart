import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/room_model.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Room>> roomsStream() {
    return _firestore
        .collection('rooms')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateRoomStatus({
    required String roomId,
    required String status,
  }) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addRoom({
    required String roomNumber,
    required String department,
    required String batch,
    required String courseName,
    required String courseTeacher,
  }) async {
    await _firestore.collection('rooms').add({
      'roomNumber': roomNumber,
      'department': department,
      'batch': batch,
      'courseName': courseName,
      'courseTeacher': courseTeacher,
      'status': 'available',
      'updatedBy': 'system', // or current user id
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
