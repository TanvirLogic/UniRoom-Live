import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniroom_live/features/auth/presentation/pages/login_page.dart';
import '../../../rooms/domain/entities/room_model.dart';
import '../../../rooms/providers/room_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../university/provider/university_provider.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({Key? key}) : super(key: key);
  static const String name = '/student-dashboard';

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final universityProvider = Provider.of<UniversityProvider>(context);

    return FutureBuilder(
      future: universityProvider.getUniversityById(
        authProvider.user!.universityId,
      ),
      builder: (context, snapshot) {
        String uniName = "Loading...";
        if (snapshot.hasData) {
          uniName = snapshot.data!.name;
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginPage.name,
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout),
              ),
            ],
            title: Text(uniName),
            centerTitle: true,
          ),
          body: StreamBuilder<List<Room>>(
            stream: roomProvider.roomsStream(
              universityId: authProvider.user!.universityId,
              department: authProvider.user!.department,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final rooms = snapshot.data!;
              if (rooms.isEmpty) {
                return const Center(
                  child: Text(
                    "No rooms found for your department.",
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
                      trailing: Chip(
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
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
