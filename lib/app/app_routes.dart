import 'package:flutter/material.dart';
import 'package:uniroom_live/features/auth/presentation/pages/forgot_password_page.dart';

import '../features/auth/presentation/pages/auth_gate.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/sign_up_page.dart';
import '../features/home/presentation/pages/cr_dashboard_page.dart';
import '../features/home/presentation/pages/student_dashboard_page.dart';

class AppRoutes {
  static Route<dynamic> routes(RouteSettings setting) {
    Widget widget = SizedBox();
    if (setting.name == AuthGate.name) {
      widget = AuthGate();
    } else if (setting.name == CRDashboardPage.name) {
      widget = CRDashboardPage();
    } else if (setting.name == LoginPage.name) {
      widget = LoginPage();
    } else if (setting.name == StudentDashboardPage.name) {
      widget = StudentDashboardPage();
    } else if (setting.name == SignUpPage.name) {
      widget = SignUpPage();
    } else if (setting.name == ForgotPasswordPage.name) {
      widget = ForgotPasswordPage();
    }

    return MaterialPageRoute(builder: (context) => widget);
  }
}
