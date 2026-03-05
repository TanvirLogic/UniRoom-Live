import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniroom_live/features/auth/presentation/pages/sign_up_page.dart';
import '../../../home/presentation/pages/cr_dashboard_page.dart';
import '../../../home/presentation/pages/student_dashboard_page.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);
  static const String name = '/auth-gate';

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    /// start listening auth changes
    authProvider.listenToAuthChanges();

    /// SPLASH SCREEN
    if (_showSplash) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// LOGO CARD
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.meeting_room_rounded,
                  size: 60,
                  color: Color(0xFF4F46E5),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "UniRoom Live",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Real-time Classroom Availability",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),

              const SizedBox(height: 40),

              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    /// AFTER SPLASH → AUTH LOGIC
    final user = authProvider.user;

    if (user == null) {
      return const LoginPage();
    }

    if (user.role == "student") {
      return const StudentDashboardPage();
    }

    if (user.role == "cr" && user.isApproved) {
      return const CRDashboardPage();
    }

    if (user.role == "cr" && !user.isApproved) {
      return const SignUpPage();
    }

    return const LoginPage();
  }
}
