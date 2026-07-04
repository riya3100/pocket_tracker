import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return "Please enter a valid email address.";

        case 'invalid-credential':
          return "Incorrect email or password.";

        case 'user-not-found':
          return "No account found with this email.";

        case 'wrong-password':
          return "Incorrect password.";

        case 'too-many-requests':
          return "Too many login attempts. Please try again later.";

        default:
          return "Login failed. Please try again.";
      }
    } catch (e) {
      return "Something went wrong.";
    }
  }

  Future<String?> signup(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "This email is already registered.";

        case 'invalid-email':
          return "Please enter a valid email address.";

        case 'weak-password':
          return "Password must be at least 6 characters.";

        default:
          return "Unable to create account.";
      }
    } catch (e) {
      return "Something went wrong.";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}