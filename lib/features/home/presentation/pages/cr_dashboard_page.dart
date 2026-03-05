import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rooms/domain/entities/room_model.dart';
import '../../../rooms/providers/room_provider.dart';

class CRDashboardPage extends StatelessWidget {
  const CRDashboardPage({Key? key}) : super(key: key);
  static const String name = '/cr-dashboard';

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: Text("Logout"),
          ),
        ],
        title: const Text("CR Control Panel"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Room>>(
        stream: roomProvider.roomsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rooms = snapshot.data!;
          if (rooms.isEmpty) {
            return const Center(
              child: Text(
                "No rooms added yet.\nTap + to add a room.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    "Room ${room.roomNumber}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "${room.department} | ${room.batch}\n${room.courseName} - ${room.courseTeacher}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      roomProvider.updateRoomStatus(
                        roomId: room.id,
                        status: value,
                      );
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "available",
                        child: Text("Mark Available"),
                      ),
                      const PopupMenuItem(
                        value: "running_class",
                        child: Text("Mark Running Class"),
                      ),
                    ],
                    child: Chip(
                      label: Text(
                        room.status == "available"
                            ? "Available"
                            : "Running Class",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: room.status == "available"
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRoomForm(context, roomProvider),
        icon: const Icon(Icons.add),
        label: const Text("Add Room"),
      ),
    );
  }

  void _showAddRoomForm(BuildContext context, RoomProvider roomProvider) {
    final roomNumberController = TextEditingController();
    final departmentController = TextEditingController();
    final batchController = TextEditingController();
    final courseController = TextEditingController();
    final teacherController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add New Room",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roomNumberController,
                decoration: const InputDecoration(labelText: "Room Number"),
              ),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: "Department"),
              ),
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: "Batch"),
              ),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: "Course Name"),
              ),
              TextField(
                controller: teacherController,
                decoration: const InputDecoration(labelText: "Course Teacher"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await roomProvider.addRoom(
                    roomNumber: roomNumberController.text,
                    department: departmentController.text,
                    batch: batchController.text,
                    courseName: courseController.text,
                    courseTeacher: teacherController.text,
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text("Save Room"),
              ),
            ],
          ),
        );
      },
    );
  }
}
