import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Ensure these paths are correct for your project
import 'package:uniroom_live/features/auth/presentation/pages/login_page.dart';
import '../../../rooms/domain/entities/room_model.dart';
import '../../../rooms/providers/room_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../university/provider/university_provider.dart';

class CRDashboardPage extends StatefulWidget {
  const CRDashboardPage({Key? key}) : super(key: key);
  static const String name = '/cr-dashboard';

  @override
  State<CRDashboardPage> createState() => _CRDashboardPageState();
}

class _CRDashboardPageState extends State<CRDashboardPage> {
  // Helper to handle Logout safely
  void _logout(AuthProvider auth) {
    auth.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginPage.name,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final universityProvider = Provider.of<UniversityProvider>(context);
    final user = authProvider.user;

    // Guard against null user during logout transition
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return FutureBuilder(
      future: universityProvider.getUniversityById(user.universityId),
      builder: (context, snapshot) {
        String uniName = snapshot.hasData
            ? snapshot.data!.name
            : "UniRoom Live";

        return Scaffold(
          backgroundColor: const Color(0xFF0D1117),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              uniName,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: () => _logout(authProvider),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user.name),
              Expanded(
                child: StreamBuilder<List<Room>>(
                  stream: roomProvider.roomsStream(
                    universityId: user.universityId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return _errorWidget(snapshot.error.toString());
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

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
            icon: const Icon(Icons.add),
            label: const Text(
              "ADD ROOM",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCRRoomCard(Room room, RoomProvider rp, AuthProvider auth) {
    bool isAvailable = room.status == "available";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withOpacity(0.02)
            : Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          "Room ${room.roomNumber}",
          style: GoogleFonts.poppins(
            color: isAvailable ? Colors.greenAccent : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        // LOGIC: All other status info removed if available
        subtitle: isAvailable
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${room.courseName} | ${room.batch}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Teacher: ${room.courseTeacher}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

        trailing: PopupMenuButton<String>(
          color: const Color(0xFF1A237E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (val) async {
            if (val == "edit") {
              _showRoomForm(context, rp, auth, room: room);
            } else if (val == "delete") {
              await rp.deleteRoom(room.id);
            } else {
              await rp.updateRoomStatus(
                roomId: room.id,
                status: val,
                updatedBy: auth.user!.name,
              );
            }
          },
          itemBuilder: (context) => [
            _menuItem(
              "available",
              "Make Vacant",
              Icons.check_circle,
              Colors.greenAccent,
            ),
            _menuItem(
              "running_class",
              "Class Running",
              Icons.timer,
              Colors.orangeAccent,
            ),
            const PopupMenuDivider(),
            _menuItem("edit", "Edit Details", Icons.edit, Colors.white70),
            _menuItem("delete", "Remove Room", Icons.delete, Colors.redAccent),
          ],
          child: _statusBadge(isAvailable),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _statusBadge(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAvailable ? "Available" : "Running Class",
        style: TextStyle(
          color: isAvailable ? Colors.greenAccent : Colors.orangeAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String val,
    String text,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MANAGEMENT PANEL",
            style: GoogleFonts.poppins(
              color: Colors.indigoAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            "Hello, $name",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget() => const Center(
    child: Text("No rooms added yet.", style: TextStyle(color: Colors.white38)),
  );

  Widget _errorWidget(String error) => Center(
    child: Text(
      "Error: $error",
      style: const TextStyle(color: Colors.redAccent),
    ),
  );

  // --- Modal Form ---

  void _showRoomForm(
    BuildContext context,
    RoomProvider rp,
    AuthProvider auth, {
    Room? room,
  }) {
    final bool isEdit = room != null;
    final rNoC = TextEditingController(text: room?.roomNumber);
    final bChC = TextEditingController(text: room?.batch);
    final cSeC = TextEditingController(text: room?.courseName);
    final tChC = TextEditingController(text: room?.courseTeacher);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A237E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? "Edit Room" : "Add New Room",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _field(rNoC, "Room Number"),
              _field(bChC, "Batch"),
              _field(cSeC, "Course Name"),
              _field(tChC, "Teacher"),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (isEdit) {
                    await rp.updateRoomDetails(
                      roomId: room.id,
                      roomNumber: rNoC.text,
                      batch: bChC.text,
                      courseName: cSeC.text,
                      courseTeacher: tChC.text,
                      updatedBy: auth.user!.name,
                    );
                  } else {
                    await rp.addRoom(
                      roomNumber: rNoC.text,
                      universityId: auth.user!.universityId,
                      department: auth.user!.department,
                      batch: bChC.text,
                      courseName: cSeC.text,
                      courseTeacher: tChC.text,
                      createdBy: auth.user!.name,
                    );
                  }
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: const Text(
                  "CONFIRM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
