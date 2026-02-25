import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user data to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'uid': userCredential.user!.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'displayName': fullName,
      'profileImage': '',
      'phoneNumber': phoneNumber,
      'role': role,
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );

    // Create user document if it doesn't exist
    final userDoc = _firestore
        .collection('users')
        .doc(userCredential.user!.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': userCredential.user!.email,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': userCredential.user!.displayName ?? 'Google User',
        'profileImage': userCredential.user!.photoURL ?? '',
        'phoneNumber': userCredential.user!.phoneNumber ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      // Update last login time
      await userDoc.update({'lastLogin': FieldValue.serverTimestamp()});
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update last login time
    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .update({'lastLogin': FieldValue.serverTimestamp()})
        .catchError((e) {
          debugPrint('Error updating last login: $e');
        });
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign Out error: $e');
    }

    try {
      await _auth.signOut();
      notifyListeners(); // Notify listeners that user is logged out
    } catch (e) {
      debugPrint('Firebase Sign Out error: $e');
      rethrow;
    }
  }
}
