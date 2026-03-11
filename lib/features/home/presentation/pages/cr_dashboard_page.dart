import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../rooms/domain/entities/room_model.dart';
import '../../../rooms/providers/room_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../university/provider/university_provider.dart';
import '../widgets/firebase_logout_button.dart';

class CRDashboardPage extends StatefulWidget {
  const CRDashboardPage({Key? key}) : super(key: key);
  static const String name = '/cr-dashboard';

  @override
  State<CRDashboardPage> createState() => _CRDashboardPageState();
}

class _CRDashboardPageState extends State<CRDashboardPage> {
  Future<void> _handleMenuAction(
      String val,
      Room room,
      RoomProvider rp,
      AuthProvider auth,
      ) async {
    if (val == "edit") {
      _showRoomForm(context, rp, auth, room: room);
    } else if (val == "delete") {
      await rp.deleteRoom(room.id);
    } else {
      await rp.updateRoomStatus(
        roomId: room.id,
        status: val,
        updatedBy: auth.user!.name,
        department: auth.user!.department, // ✅ reassign ownership
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final universityProvider = Provider.of<UniversityProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder(
      future: universityProvider.getUniversityById(user.universityId),
      builder: (context, snapshot) {
        String uniName = snapshot.hasData ? snapshot.data!.name : "UniRoom Live";

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                uniName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              actions: [FireBaseLogoutButton(authProvider: authProvider)],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user.name),
                Expanded(
                  child: StreamBuilder<List<Room>>(
                    stream: roomProvider.allRoomsStream(
                      universityId: user.universityId, // ✅ CRs see all rooms
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _errorWidget(snapshot.error.toString());
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final rooms = snapshot.data!;
                      if (rooms.isEmpty) return _emptyWidget();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) => _buildCRRoomCard(
                          rooms[index],
                          roomProvider,
                          authProvider,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF3F51B5),
              onPressed: () => _showRoomForm(context, roomProvider, authProvider),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "ADD ROOM",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "Welcome, $name (CR)",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCRRoomCard(Room room, RoomProvider rp, AuthProvider auth) {
    bool isAvailable = room.status == "available";
    bool isOccupied = room.status == "running_class";

    return Card(
      color: const Color(0xFF161B22),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(
          "${room.roomNumber} (${room.department})", // show dept ownership
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isAvailable ? "Available" : "Running Class",
          style: TextStyle(
            color: isAvailable ? Colors.greenAccent : Colors.orangeAccent,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) => _handleMenuAction(val, room, rp, auth),
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
            const PopupMenuItem(value: "available", child: Text("Mark Available")),
            const PopupMenuItem(value: "running_class", child: Text("Mark Running")),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(String error) {
    return Center(
      child: Text(
        "Error: $error",
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _emptyWidget() {
    return const Center(
      child: Text(
        "No rooms found.",
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  void _showRoomForm(BuildContext context, RoomProvider rp, AuthProvider auth,
      {Room? room}) {
    final roomNumberController = TextEditingController(text: room?.roomNumber ?? '');
    final batchController = TextEditingController(text: room?.batch ?? '');
    final courseNameController = TextEditingController(text: room?.courseName ?? '');
    final courseTeacherController = TextEditingController(text: room?.courseTeacher ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(
          room == null ? "Add Room" : "Edit Room",
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: roomNumberController,
                decoration: const InputDecoration(labelText: "Room Number"),
              ),
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: "Batch"),
              ),
              TextField(
                controller: courseNameController,
                decoration: const InputDecoration(labelText: "Course Name"),
              ),
              TextField(
                controller: courseTeacherController,
                decoration: const InputDecoration(labelText: "Course Teacher"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (room == null) {
                await rp.addRoom(
                  roomNumber: roomNumberController.text,
                  universityId: auth.user!.universityId,
                  department: auth.user!.department,
                  batch: batchController.text,
                  courseName: courseNameController.text,
                  courseTeacher: courseTeacherController.text,
                  createdBy: auth.user!.name,
                );
              } else {
                await rp.updateRoomDetails(
                  roomId: room.id,
                  roomNumber: roomNumberController.text,
                  batch: batchController.text,
                  courseName: courseNameController.text,
                  courseTeacher: courseTeacherController.text,
                  updatedBy: auth.user!.name,
                  department: auth.user!.department, // ✅ reassign ownership
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}