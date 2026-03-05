
import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/login_page.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class FireBaseLogoutButton extends StatelessWidget {
  const FireBaseLogoutButton({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // Show confirmation dialog before logging out
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(
                0xFF1A237E,
              ), // Matches your brand colors
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Are you sure you want to log out of UniRoom Live?",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                // Confirm Logout Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Perform logout
                    authProvider.logout();
                    // Navigate to Login Page
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginPage.name,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.logout_rounded, color: Colors.white70),
    );
  }
}
