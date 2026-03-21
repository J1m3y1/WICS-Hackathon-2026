import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Checks if user exists
  Future<UserCredential> signInWithEmailPassword( {
    required String email,
    required String password
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }
  //Creates a user
  Future<UserCredential> createUserWithEmailPassword( {
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );
  }
  //Signs out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}