import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your pages
import 'package:uniroom_live/features/auth/presentation/pages/login_page.dart';
import 'package:uniroom_live/features/auth/presentation/pages/sign_up_page.dart';
import '../../../home/presentation/pages/cr_dashboard_page.dart';
import '../../../home/presentation/pages/student_dashboard_page.dart';
import '../providers/auth_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);
  static const String name = '/auth-gate';

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Start listening to auth changes
    await authProvider.listenToAuthChanges();

    // Short splash delay (only for animation effect)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    _navigateUser(authProvider);
  }

  void _navigateUser(AuthProvider auth) {
    final user = auth.user;

    if (user == null) {
      _goTo(const LoginPage());
      return;
    }

    if (user.role == "student") {
      _goTo(const StudentDashboardPage());
      return;
    }

    if (user.role == "cr") {
      if (user.isApproved) {
        _goTo(const CRDashboardPage());
      } else {
        // Pending approval → show signup or custom pending page
        _goTo(const SignUpPage());
      }
    }
  }

  void _goTo(Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1117), Color(0xFF1A237E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(
                  Icons.meeting_room_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "UniRoom Live",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Smart Classroom Tracking",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
