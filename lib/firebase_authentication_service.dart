import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen for auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Return user credential
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user document from Firestore
      final userDoc = await _firestore.collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // If no document exists, create one with basic details
      if (!userDoc.exists) {
        await _firestore.collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'fullName': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'phoneNumber': userCredential.user!.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Handle specific Pigeon error case
      if (e.toString().contains('PigeonUserDetails')) {
        print('Caught Pigeon error, but authentication was successful');
        throw 'Authentication successful but encountered an app error. Please restart the app.';
      }
      throw 'An unexpected error occurred: $e';
    }
  }


  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user details
// In your firebase_authentication_service.dart file
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No authenticated user found');
        return null;
      }

      // Get the user document from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        print('User document found: ${docSnapshot.data()}');
        return docSnapshot.data();
      } else {
        print('User document does not exist for uid: ${user.uid}');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? timezone,
    String? currency,
  }) async {
    if (currentUser == null) return;

    Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (timezone != null) data['timezone'] = timezone;
    if (currency != null) data['currency'] = currency;

    await _firestore.collection('users').doc(currentUser!.uid).update(data);
  }

  // Helper to handle Firebase auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already in use. Please use a different email or sign in.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}