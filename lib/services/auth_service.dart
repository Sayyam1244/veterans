import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scheduled_notification_manager.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthResult(success: true, user: result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'An unexpected error occurred. Please try again.');
    }
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);

        // Create user document in Firestore
        await _createUserDocument(user: result.user!, name: name, phone: phone, dateOfBirth: dateOfBirth);

        return AuthResult(success: true, user: result.user);
      } else {
        return AuthResult(success: false, errorMessage: 'Failed to create account. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'An unexpected error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(success: true, message: 'Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to send password reset email. Please try again.',
      );
    }
  }

  // Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user account
        await user.delete();

        return AuthResult(success: true, message: 'Account deleted successfully.');
      } else {
        return AuthResult(success: false, errorMessage: 'No user found to delete.');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Failed to delete account. Please try again.');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required User user,
    required String name,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVeteran': true, // Default value for this app
        'emergencyContacts': [],
        'preferences': {'notifications': true, 'profileVisibility': 'public', 'postVisibility': 'public'},
      });

      // Send welcome notification after a short delay to ensure user document is created
      Future.delayed(const Duration(seconds: 2), () {
        ScheduledNotificationManager().sendWelcomeNotification();
      });
    } catch (e) {
      throw Exception('Failed to create user profile. Please try again.');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data.');
    }
  }

  // Update user data in Firestore
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        data['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(user.uid).update(data);
        return true;
      }
      return false;
    } catch (e) {
      log('Error updating user data: $e');
      return false;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get Firebase Auth error messages in user-friendly format
  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'requires-recent-login':
        return 'This action requires recent authentication. Please sign in again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

// Result class for auth operations
class AuthResult {
  final bool success;
  final User? user;
  final String? errorMessage;
  final String? message;

  AuthResult({required this.success, this.user, this.errorMessage, this.message});
}

// User model for easier data handling
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVeteran;
  final List<dynamic> emergencyContacts;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    this.profileImageUrl = '',
    this.createdAt,
    this.updatedAt,
    this.isVeteran = true,
    this.emergencyContacts = const [],
    this.preferences = const {},
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      isVeteran: map['isVeteran'] ?? true,
      emergencyContacts: map['emergencyContacts'] ?? [],
      preferences: map['preferences'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'profileImageUrl': profileImageUrl,
      'isVeteran': isVeteran,
      'emergencyContacts': emergencyContacts,
      'preferences': preferences,
    };
  }
}
