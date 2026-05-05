import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user data
  User? get currentUser => _auth.currentUser;

  // Stream to track auth changes (Login/Logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- 1. Sign In Method ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Throwing specific errors to show in the UI SnackBar
      if (e.code == 'user-not-found')
        throw Exception("No user found with this email.");
      if (e.code == 'wrong-password') throw Exception("Incorrect password.");
      throw Exception(e.message ?? "Login failed.");
    }
  }

  // --- 2. Sign Up Method ---
  Future<User?> signUp(String email, String password, {String? name}) async {
    try {
      // Create account in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Update Display Name in Auth Profile
        if (name != null) {
          await user.updateDisplayName(name);
          await user.reload();
          user = _auth.currentUser;
        }

        // Create the main User document in Firestore with Default Settings
        await _firestore.collection('Users').doc(user!.uid).set({
          'displayName': name ?? 'New User',
          'email': email,
          'photoUrl': '',
          'emailNotifications': true,
          'pushNotifications': false,
          'inAppPromotions': true,
          'twoFactorAuth': false, // Changed to false as default
          'autoApproveOffers': true,
          'language': 'English',
          'currency': 'USD',
          'units': 'Metric',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // --- Optional: Dummy data for testing UI (Keep if needed) ---
        // 1. Default Payment Method
        await _firestore
            .collection('Users')
            .doc(user.uid)
            .collection('paymentMethods')
            .add({
              'type': 'Visa',
              'last4': '4242',
              'expires': '08/26',
              'primary': true,
            });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use')
        throw Exception("Email is already registered.");
      if (e.code == 'weak-password') throw Exception("Password is too weak.");
      throw Exception(e.message ?? "Registration failed.");
    }
  }

  // --- 3. Sign Out Method ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
