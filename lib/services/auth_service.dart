import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<User?> register(String email, String password) async {
    try {
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
    );

    return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.toString();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw e.toString();
    }
  }
}