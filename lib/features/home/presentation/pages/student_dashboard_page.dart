import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniroom_live/features/auth/presentation/pages/login_page.dart';
import '../../../rooms/domain/entities/room_model.dart';
import '../../../rooms/providers/room_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../university/provider/university_provider.dart';
import '../widgets/firebase_logout_button.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({Key? key}) : super(key: key);
  static const String name = '/student-dashboard';

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final universityProvider = Provider.of<UniversityProvider>(context);
    final user = authProvider.user;

    // ✅ Handle null user safely
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder(
      future: universityProvider.getUniversityById(user.universityId),
      builder: (context, snapshot) {
        String uniName = snapshot.hasData
            ? snapshot.data!.name
            : "Loading University...";

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                uniName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              actions: [FireBaseLogoutButton(authProvider: authProvider)],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome & Department Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${user.name.split(' ')[0]} 👋",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Department of ${user.department}",
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live Room Stream
                Expanded(
                  child: StreamBuilder<List<Room>>(
                    stream: roomProvider.roomsStream(
                      universityId: user.universityId,
                      department: user.department,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildStatusMessage("Something went wrong");
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final rooms = snapshot.data!;
                      if (rooms.isEmpty) {
                        return _buildStatusMessage(
                          "No live rooms found for your department.",
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) =>
                            _buildRoomCard(rooms[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomCard(Room room) {
    bool isAvailable = room.status == "available";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Room Number Avatar
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAvailable
                      ? [Colors.green.shade400, Colors.green.shade700]
                      : [Colors.orange.shade400, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  room.roomNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Room Details (conditional)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isAvailable) ...[
                    Text(
                      room.courseName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Teacher: ${room.courseTeacher}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isAvailable ? Colors.green : Colors.orange)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? "● Available Now" : "● Running Class",
                      style: TextStyle(
                        color: isAvailable
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Batch Info (only if running class)
            if (!isAvailable)
              Column(
                children: [
                  const Text(
                    "Batch",
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  Text(
                    room.batch,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(String msg) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(color: Colors.white54, fontSize: 16),
      ),
    );
  }
}
