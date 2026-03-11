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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Theme Colors
  final Color primaryIndigo = const Color(0xFF3F51B5);
  final Color darkBg = const Color(0xFF0D1117);
  final Color cardColor = const Color(0xFF161B22);

  Future<void> _handleMenuAction(String val, Room room, RoomProvider rp, AuthProvider auth) async {
    if (val == "edit") {
      _showRoomForm(context, rp, auth, room: room);
    } else if (val == "delete") {
      _confirmDelete(room, rp);
    } else {
      await rp.updateRoomStatus(
        roomId: room.id,
        status: val,
        updatedBy: auth.user!.name,
        department: auth.user!.department,
      );
    }
  }

  void _confirmDelete(Room room, RoomProvider rp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text("Delete Room?", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to remove ${room.roomNumber}?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              rp.deleteRoom(room.id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final universityProvider = Provider.of<UniversityProvider>(context);
    final user = authProvider.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: darkBg,
          elevation: 0,
          title: FutureBuilder(
            future: universityProvider.getUniversityById(user.universityId),
            builder: (context, snapshot) => Text(
              snapshot.hasData ? snapshot.data!.name : "UniRoom Live",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
            ),
          ),
          actions: [FireBaseLogoutButton(authProvider: authProvider)],
        ),
        body: Column(
          children: [
            _buildEnhancedHeader(user.name),
            _buildSearchBar(),
            Expanded(
              child: StreamBuilder<List<Room>>(
                stream: roomProvider.allRoomsStream(universityId: user.universityId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  // Filter rooms based on search
                  final rooms = snapshot.data!.where((r) =>
                  r.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      r.department.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();

                  if (rooms.isEmpty) return _emptyWidget();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) => _buildModernRoomCard(rooms[index], roomProvider, authProvider),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: primaryIndigo,
          onPressed: () => _showRoomForm(context, roomProvider, authProvider),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text("ADD ROOM", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello CR,", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
          Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search room or department...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildModernRoomCard(Room room, RoomProvider rp, AuthProvider auth) {
    bool isAvailable = room.status == "available";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showActionSheet(room, rp, auth), // Tapping the tile opens actions
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Status Indicator Icon
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAvailable ? Icons.event_available : Icons.class_,
                  color: isAvailable ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.roomNumber,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      room.department,
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Vertical Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: cardColor,
                onSelected: (val) => _handleMenuAction(val, room, rp, auth),
                itemBuilder: (context) => [
                  _buildPopupItem("edit", Icons.edit_outlined, "Edit Room"),
                  _buildPopupItem("available", Icons.check_circle_outline, "Set Available"),
                  _buildPopupItem("running_class", Icons.timer_outlined, "Set Running"),
                  const PopupMenuDivider(),
                  _buildPopupItem("delete", Icons.delete_outline, "Delete", color: Colors.redAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, {Color color = Colors.white}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 20),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  // Action Sheet for Tapping Tile
  void _showActionSheet(Room room, RoomProvider rp, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Room ${room.roomNumber}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Details", style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _handleMenuAction("edit", room, rp, auth); },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text("Mark Available", style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _handleMenuAction("available", room, rp, auth); },
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomForm(BuildContext context, RoomProvider rp, AuthProvider auth, {Room? room}) {
    final roomNo = TextEditingController(text: room?.roomNumber ?? '');
    final batch = TextEditingController(text: room?.batch ?? '');
    final course = TextEditingController(text: room?.courseName ?? '');
    final teacher = TextEditingController(text: room?.courseTeacher ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(room == null ? "✨ New Room" : "📝 Edit Room", style: GoogleFonts.poppins(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(roomNo, "Room Number", Icons.meeting_room),
              _buildField(batch, "Batch", Icons.people),
              _buildField(course, "Course Name", Icons.book),
              _buildField(teacher, "Course Teacher", Icons.person),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo, shape: StadiumBorder()),
            onPressed: () async {
              if (room == null) {
                await rp.addRoom(
                  roomNumber: roomNo.text,
                  universityId: auth.user!.universityId,
                  department: auth.user!.department,
                  batch: batch.text,
                  courseName: course.text,
                  courseTeacher: teacher.text,
                  createdBy: auth.user!.name,
                );
              } else {
                await rp.updateRoomDetails(
                  roomId: room.id,
                  roomNumber: roomNo.text,
                  batch: batch.text,
                  courseName: course.text,
                  courseTeacher: teacher.text,
                  updatedBy: auth.user!.name,
                  department: auth.user!.department,
                );
              }
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Save Room", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryIndigo, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryIndigo)),
        ),
      ),
    );
  }

  Widget _emptyWidget() => const Center(child: Text("No rooms found.", style: TextStyle(color: Colors.white54)));
}