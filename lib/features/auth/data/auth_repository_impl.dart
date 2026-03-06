import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> signUp({
    required String name,
    required String email,
    required String password,
    required String universityId,
    required String role,
    required String department,
    required String batch,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userDoc = {
      'name': name,
      'email': email,
      'role': role,
      'universityId': universityId,
      'department': department,
      'batch': batch,
      'isApproved': role == 'cr' ? false : true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .set(userDoc);

    return AppUser(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      role: role,
      universityId: universityId,
      department: department,
      batch: batch,
      isApproved: role == 'cr' ? false : true,
    );
  }

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    return AppUser.fromFirestore(doc);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Stream<AppUser?> getCurrentUser() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return AppUser.fromFirestore(doc);
    });
  }

  @override
  Future<AppUser?> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      throw e;
    }
  }
}
