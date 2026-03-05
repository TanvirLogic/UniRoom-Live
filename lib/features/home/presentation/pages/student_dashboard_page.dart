import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rooms/domain/entities/room_model.dart';
import '../../../rooms/providers/room_provider.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({Key? key}) : super(key: key);
  static const String name = '/auth-gate';
  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
        title: const Text("Student Dashboard"),
      ),
      body: StreamBuilder<List<Room>>(
        stream: roomProvider.roomsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rooms = snapshot.data!;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Card(
                child: ListTile(
                  title: Text("Room ${room.roomNumber}"),
                  subtitle: Text(
                    "${room.department} | ${room.batch}\n${room.courseName} - ${room.courseTeacher}",
                  ),
                  trailing: Chip(
                    label: Text(
                      room.status == "available"
                          ? "Available"
                          : "Running Class",
                    ),
                    backgroundColor: room.status == "available"
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
