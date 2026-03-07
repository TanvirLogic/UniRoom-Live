import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniroom_live/features/auth/presentation/pages/login_page.dart';
import 'package:uniroom_live/features/home/presentation/pages/student_dashboard_page.dart';
import '../../../university/domain/entity/university_model.dart';
import '../../../university/provider/university_provider.dart';
import '../providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  static const String name = '/sign-up-gate';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for better UX
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();

  University? _selectedUniversity;
  String? _selectedDept;
  String _role = "student";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<UniversityProvider>(
        context,
        listen: false,
      ).fetchUniversities(),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate() ||
        _selectedUniversity == null ||
        _selectedDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passController.text,
        universityId: _selectedUniversity!.id,
        role: _role,
        department: _selectedDept!,
        batch: _batchController.text.trim(),
      );

      if (authProvider.user != null && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          StudentDashboardPage.name,
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniProvider = Provider.of<UniversityProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Navigator.pushReplacementNamed(context, LoginPage.name);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Theme-consistent background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginPage.name,
                          (route) => false,
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Create Account",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Join your university community",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 30),

                      // Input Fields
                      _buildInputField(
                        controller: _nameController,
                        hint: "Full Name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        controller: _emailController,
                        hint: "University Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        controller: _passController,
                        hint: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),

                      // University Dropdown
                      _buildDropdownContainer(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<University>(
                            value: _selectedUniversity,
                            hint: const Text(
                              "Select University",
                              style: TextStyle(color: Colors.white54),
                            ),
                            dropdownColor: const Color(0xFF1A237E),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white70,
                            ),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white),
                            items: uniProvider.universities
                                .map(
                                  (uni) => DropdownMenuItem(
                                    value: uni,
                                    child: Text(uni.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setState(() {
                              _selectedUniversity = val;
                              _selectedDept = null;
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Dynamic Department Dropdown
                      if (_selectedUniversity != null) ...[
                        _buildDropdownContainer(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDept,
                              hint: const Text(
                                "Select Department",
                                style: TextStyle(color: Colors.white54),
                              ),
                              dropdownColor: const Color(0xFF1A237E),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white70,
                              ),
                              isExpanded: true,
                              style: const TextStyle(color: Colors.white),
                              items: _selectedUniversity!.departments
                                  .map(
                                    (dept) => DropdownMenuItem(
                                      value: dept,
                                      child: Text(dept),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedDept = val),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],

                      _buildInputField(
                        controller: _batchController,
                        hint: "Batch (e.g. 2024)",
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 25),

                      // Role Selection
                      Text(
                        "Register as:",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          _roleOption("student", "Student"),
                          const SizedBox(width: 20),
                          _roleOption("cr", "Class Rep (CR)"),
                        ],
                      ),
                      if (_role == "cr")
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "⚠️ CR accounts require manual admin verification.",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "CREATE ACCOUNT",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Developed by Md Tanvir Ahmed',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _roleOption(String value, String label) {
    bool isSelected = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 2),
              color: isSelected ? Colors.blueAccent : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
