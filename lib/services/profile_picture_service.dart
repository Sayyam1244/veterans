import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery or camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  // Upload profile picture and update user document
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      // Create a reference to the storage location
      final Reference ref = _storage.ref().child('profile_pictures').child('${user.uid}.jpg');

      // Upload the file
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the user document in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile picture: $e');
      }
      return null;
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      // Delete from storage (if exists)
      try {
        final Reference ref = _storage.ref().child('profile_pictures').child('${user.uid}.jpg');

        await ref.delete();
      } catch (e) {
        // File might not exist in storage, continue with Firestore update
        if (kDebugMode) {
          print('File not found in storage: $e');
        }
      }

      // Update the user document in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting profile picture: $e');
      }
      return false;
    }
  }

  // Get profile picture URL
  Future<String?> getProfilePictureUrl() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['profileImageUrl'] as String?;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting profile picture URL: $e');
      }
      return null;
    }
  }
}
