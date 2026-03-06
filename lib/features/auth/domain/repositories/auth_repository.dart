import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> signUp({
    required String name,
    required String email,
    required String password,
    required String universityId,
    required String role,
    required String department,
    required String batch,
  });

  Future<AppUser?> login({required String email, required String password});
  Future<AppUser?> forgotPassword({required String email});

  Future<void> logout();

  Stream<AppUser?> getCurrentUser();
}
