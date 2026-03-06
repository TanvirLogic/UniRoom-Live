import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  AppUser? _user;
  AppUser? get user => _user;

  AuthProvider(this._authRepository);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String universityId,
    required String role,
    required String department,
    required String batch,
  }) async {
    _user = await _authRepository.signUp(
      name: name,
      email: email,
      password: password,
      universityId: universityId,
      role: role,
      department: department,
      batch: batch,
    );
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await _authRepository.login(email: email, password: password);
    notifyListeners();
  }

  Future<void> forgotPass(String email) async {
    _user = await _authRepository.forgotPassword(email: email);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> listenToAuthChanges() async {
    // 1. We get the stream from the repository
    final stream = _authRepository.getCurrentUser();

    // 2. We "await" the very first value from the stream (the current user)
    // This ensures _user is populated before the splash screen finishes
    _user = await stream.first;
    notifyListeners();

    // 3. We then continue to listen for future changes (like logging out)
    stream.listen((appUser) {
      _user = appUser;
      notifyListeners();
    });
  }
}