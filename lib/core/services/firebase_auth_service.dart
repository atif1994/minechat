import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email/Password Authentication
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email Verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Re-authenticate Account while Deleting Account
  Future<void> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No authenticated user.';
      final cred =
          EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  // Getters
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Error Handling
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email address. Please use a different email or try signing in.';
        case 'weak-password':
          return 'The password provided is too weak. Please use at least 8 characters with uppercase, lowercase, numbers, and symbols.';
        case 'invalid-email':
          return 'The email address is not valid. Please enter a valid email address.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'requires-recent-login':
          return 'This operation requires recent authentication.';
        case 'invalid-credential':
          return 'Invalid credentials. Please check your email and password.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'recaptcha-check-failed':
          return 'reCAPTCHA verification failed. Please try again.';
        case 'recaptcha-not-enabled':
          return 'reCAPTCHA is not enabled for this project.';
        case 'recaptcha-invalid-site-key':
          return 'reCAPTCHA site key is invalid.';
        case 'recaptcha-invalid-response':
          return 'reCAPTCHA response is invalid. Please try again.';
        default:
          return 'Authentication failed: ${e.message}';
      }
    }

    // Handle string-based errors (like the reCAPTCHA error you're seeing)
    String errorString = e.toString();
    if (errorString.contains('email address is already in use')) {
      return 'An account already exists with this email address. Please use a different email or try signing in.';
    } else if (errorString.contains('RecaptchaCallWrapper')) {
      return 'reCAPTCHA verification failed. Please try again.';
    } else if (errorString.contains('sign_in_failed')) {
      return 'Sign-in failed. Please try again.';
    }

    return 'An unexpected error occurred: $e';
  }
}
