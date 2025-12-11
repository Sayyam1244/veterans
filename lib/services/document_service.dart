import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';

enum DocumentCategory { medical, benefits, identification, discharge, insurance, other }

class UserDocument {
  final String id;
  final String name;
  final String fileName;
  final String base64Data;
  final DocumentCategory category;
  final int size;
  final String mimeType;
  final DateTime uploadedAt;
  final DateTime? expiryDate;
  final Map<String, dynamic>? metadata;

  UserDocument({
    required this.id,
    required this.name,
    required this.fileName,
    required this.base64Data,
    required this.category,
    required this.size,
    required this.mimeType,
    required this.uploadedAt,
    this.expiryDate,
    this.metadata,
  });

  factory UserDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDocument(
      id: doc.id,
      name: data['name'] ?? '',
      fileName: data['fileName'] ?? '',
      base64Data: data['base64Data'] ?? '',
      category: DocumentCategory.values.firstWhere(
        (e) => e.toString() == 'DocumentCategory.${data['category']}',
        orElse: () => DocumentCategory.other,
      ),
      size: data['size'] ?? 0,
      mimeType: data['mimeType'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      expiryDate: data['expiryDate'] != null ? (data['expiryDate'] as Timestamp).toDate() : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'fileName': fileName,
      'base64Data': base64Data,
      'category': category.toString().split('.').last,
      'size': size,
      'mimeType': mimeType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'metadata': metadata,
    };
  }
}

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Maximum file size: 500KB
  static const int maxFileSizeBytes = 500 * 1024;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Upload a document
  Future<String?> uploadDocument({
    required File file,
    required String documentName,
    required DocumentCategory category,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return null;

      // Check file size limit
      final fileStat = await file.stat();
      if (fileStat.size > maxFileSizeBytes) {
        throw Exception(
          'File size exceeds 500KB limit. Current size: ${(fileStat.size / 1024).toStringAsFixed(1)}KB',
        );
      }

      // Read file and convert to base64
      final Uint8List fileBytes = await file.readAsBytes();
      final String base64Data = base64Encode(fileBytes);

      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalFileName = file.path.split('/').last;
      final fileName = '${timestamp}_$originalFileName';
      final mimeType = _getMimeType(file.path);

      // Save document info to Firestore with base64 data
      final docRef = await _firestore.collection('users').doc(currentUserId).collection('documents').add({
        'name': documentName,
        'fileName': fileName,
        'base64Data': base64Data,
        'category': category.toString().split('.').last,
        'size': fileStat.size,
        'mimeType': mimeType,
        'uploadedAt': FieldValue.serverTimestamp(),
        'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
        'metadata': metadata,
      });

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading document: $e');
      }
      rethrow;
    }
  }

  // Get all documents for current user
  Stream<List<UserDocument>> getUserDocuments() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('documents')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserDocument.fromFirestore(doc)).toList());
  }

  // Get documents by category
  Stream<List<UserDocument>> getDocumentsByCategory(DocumentCategory category) {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('documents')
        .where('category', isEqualTo: category.toString().split('.').last)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserDocument.fromFirestore(doc)).toList());
  }

  // Delete a document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return false;

      // Get document data first to delete from storage
      final docSnapshot =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('documents')
              .doc(documentId)
              .get();

      if (docSnapshot.exists) {
        // Since we're using base64 storage, no need to delete from Firebase Storage
        // Just delete the document record from Firestore
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('documents')
            .doc(documentId)
            .delete();

        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
      return false;
    }
  }

  // Update document metadata
  Future<bool> updateDocument({
    required String documentId,
    String? name,
    DocumentCategory? category,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return false;

      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category.toString().split('.').last;
      if (expiryDate != null) updateData['expiryDate'] = Timestamp.fromDate(expiryDate);
      if (metadata != null) updateData['metadata'] = metadata;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('documents')
          .doc(documentId)
          .update(updateData);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating document: $e');
      }
      return false;
    }
  }

  // Get documents that are expiring soon (within 30 days)
  Stream<List<UserDocument>> getExpiringSoonDocuments() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('documents')
        .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(thirtyDaysFromNow))
        .where('expiryDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserDocument.fromFirestore(doc)).toList());
  }

  // Get storage usage for current user
  Future<int> getStorageUsage() async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _firestore.collection('users').doc(currentUserId).collection('documents').get();

      int totalSize = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalSize += (data['size'] as int?) ?? 0;
      }

      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating storage usage: $e');
      }
      return 0;
    }
  }

  // Helper method to determine MIME type
  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  // Get category display name
  static String getCategoryDisplayName(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.medical:
        return 'Medical Records';
      case DocumentCategory.benefits:
        return 'Benefits & Claims';
      case DocumentCategory.identification:
        return 'Identification';
      case DocumentCategory.discharge:
        return 'Discharge Papers';
      case DocumentCategory.insurance:
        return 'Insurance Documents';
      case DocumentCategory.other:
        return 'Other Documents';
    }
  }

  // Get category icon
  static String getCategoryIcon(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.medical:
        return 'stethoscope.svg';
      case DocumentCategory.benefits:
        return 'star.svg';
      case DocumentCategory.identification:
        return 'profile.svg';
      case DocumentCategory.discharge:
        return 'doc.svg';
      case DocumentCategory.insurance:
        return 'sheild.svg';
      case DocumentCategory.other:
        return 'page.svg';
    }
  }
}
