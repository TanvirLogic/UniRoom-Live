import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/presentation/pages/auth_gate.dart';
import '../features/auth/presentation/providers/auth_provider.dart'
    show AuthProvider;
import '../features/rooms/providers/room_provider.dart';
import '../features/university/provider/university_provider.dart';

import 'app_routes.dart';

class UniRoomLive extends StatefulWidget {
  const UniRoomLive({super.key});

  @override
  State<UniRoomLive> createState() => _UniRoomLiveState();
}

class _UniRoomLiveState extends State<UniRoomLive> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepositoryImpl()),
        ),
        ChangeNotifierProvider(create: (_) => UniversityProvider()),
        ChangeNotifierProvider(
          create: (_) => RoomProvider(), // <-- inject RoomProvider globally
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthGate(), // entry point
        onGenerateRoute: AppRoutes.routes,
      ),
    );
  }
}
