import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniroom_live/features/auth/presentation/pages/sign_up_page.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const String name = '/auth-gate';
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Email"),
                onSaved: (val) => _email = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => _password = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  _formKey.currentState?.save();
                  if (_email == null || _password == null) return;

                  await authProvider.login(_email!, _password!);

                  final user = authProvider.user;
                  if (user == null) return;

                  // Role-based navigation
                  if (user.role == "student") {
                    Navigator.pushReplacementNamed(context, "/dashboard");
                  } else if (user.role == "cr" && user.isApproved) {
                    Navigator.pushReplacementNamed(context, "/dashboard");
                  } else if (user.role == "cr" && !user.isApproved) {
                    Navigator.pushReplacementNamed(context, "/waiting");
                  }
                },
                child: const Text("Login"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    SignUpPage.name,
                    (route) => false,
                  );
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
