import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String roomNumber;
  final String universityId;
  final String department; // ✅ single department owner
  final String batch;
  final String courseName;
  final String courseTeacher;
  final String status; // available | running_class
  final String updatedBy;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.roomNumber,
    required this.universityId,
    required this.department,
    required this.batch,
    required this.courseName,
    required this.courseTeacher,
    required this.status,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      roomNumber: data['roomNumber'] ?? '',
      universityId: data['universityId'] ?? '',
      department: data['department'] ?? '',
      batch: data['batch'] ?? '',
      courseName: data['courseName'] ?? '',
      courseTeacher: data['courseTeacher'] ?? '',
      status: data['status'] ?? 'available',
      updatedBy: data['updatedBy'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomNumber': roomNumber,
      'universityId': universityId,
      'department': department,
      'batch': batch,
      'courseName': courseName,
      'courseTeacher': courseTeacher,
      'status': status,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
    };
  }
}