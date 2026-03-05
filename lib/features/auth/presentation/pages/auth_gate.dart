import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniroom_live/features/auth/presentation/pages/sign_up_page.dart';
import '../../../home/presentation/pages/cr_dashboard_page.dart';
import '../../../home/presentation/pages/student_dashboard_page.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);
  static const String name = '/auth-gate';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Start listening to auth changes
    authProvider.listenToAuthChanges();

    final user = authProvider.user;

    if (user == null) {
      // Not logged in → show login/signup
      return const LoginPage();
    }

    if (user.role == "student") {
      // Student → Student Dashboard
      return const StudentDashboardPage();
    }

    if (user.role == "cr" && user.isApproved) {
      // Approved CR → CR Dashboard
      return const CRDashboardPage();
    }

    if (user.role == "cr" && !user.isApproved) {
      // CR not approved yet → show waiting screen
      return const SignUpPage(); // or a dedicated WaitingPage if you prefer
    }

    // Fallback
    return const LoginPage();
  }
}
