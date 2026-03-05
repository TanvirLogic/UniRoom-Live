import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  String? _name;
  String? _email;
  String? _password;
  String? _department;
  String? _batch;
  String? _role = "student";
  University? _selectedUniversity;

  @override
  void initState() {
    super.initState();
    // Fetch universities when screen loads
    Future.microtask(
          () => Provider.of<UniversityProvider>(
        context,
        listen: false,
      ).fetchUniversities(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final universityProvider = Provider.of<UniversityProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Full Name"),
                onSaved: (val) => _name = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Email"),
                onSaved: (val) => _email = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => _password = val,
              ),

              // University dropdown
              DropdownButtonFormField<University>(
                decoration: const InputDecoration(labelText: "University"),
                items: universityProvider.universities
                    .map(
                      (uni) => DropdownMenuItem(
                    value: uni,
                    child: Text(uni.name),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedUniversity = val;
                    _department = null; // reset department when university changes
                  });
                },
              ),

              // Department dropdown (dynamic based on university)
              if (_selectedUniversity != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Department"),
                  items: _selectedUniversity!.departments
                      .map(
                        (dept) => DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    ),
                  )
                      .toList(),
                  onChanged: (val) => setState(() => _department = val),
                ),

              TextFormField(
                decoration: const InputDecoration(labelText: "Batch"),
                onSaved: (val) => _batch = val,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Student"),
                      value: "student",
                      groupValue: _role,
                      onChanged: (val) => setState(() => _role = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("CR"),
                      value: "cr",
                      groupValue: _role,
                      onChanged: (val) => setState(() => _role = val),
                    ),
                  ),
                ],
              ),
              if (_role == "cr")
                const Text(
                  "CR accounts require admin approval.",
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.save();
                  if (_selectedUniversity == null || _department == null) return;

                  await authProvider.signUp(
                    name: _name!,
                    email: _email!,
                    password: _password!,
                    universityId: _selectedUniversity!.id,
                    role: _role!,
                    department: _department!,
                    batch: _batch!,
                  );

                  // Navigate after signup
                  if (authProvider.user != null) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      StudentDashboardPage.name,
                          (route) => false,
                    );
                  }
                },
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}