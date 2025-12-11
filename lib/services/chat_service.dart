import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Start a conversation with a user
  Future<String?> startConversation(String otherUserId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return null;

      // Create conversation ID by combining user IDs in alphabetical order
      final List<String> userIds = [currentUserId, otherUserId];
      userIds.sort();
      final conversationId = userIds.join('_');

      // Check if conversation already exists
      final conversationDoc = await _firestore.collection('conversations').doc(conversationId).get();

      if (!conversationDoc.exists) {
        // Create new conversation
        await _firestore.collection('conversations').doc(conversationId).set({
          'participants': userIds,
          'participantDetails': {
            currentUserId: {
              'uid': currentUserId,
              'name': currentUser?.displayName ?? 'Unknown',
              'email': currentUser?.email ?? '',
            },
          },
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return conversationId;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting conversation: $e');
      }
      return null;
    }
  }

  // Send a message
  Future<bool> sendMessage(String conversationId, String message) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null || message.trim().isEmpty) return false;

      // Add message to messages subcollection
      await _firestore.collection('conversations').doc(conversationId).collection('messages').add({
        'senderId': currentUserId,
        'senderName': currentUser?.displayName ?? 'Unknown',
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'messageType': 'text',
      });

      // Update conversation with last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': message.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      return false;
    }
  }

  // Get conversations for current user
  Stream<List<ChatConversation>> getConversations() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatConversation.fromFirestore(doc);
          }).toList();
        });
  }

  // Get messages for a conversation
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessage.fromFirestore(doc);
          }).toList();
        });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return;

      final batch = _firestore.batch();

      final unreadMessages =
          await _firestore
              .collection('conversations')
              .doc(conversationId)
              .collection('messages')
              .where('senderId', isNotEqualTo: currentUserId)
              .where('isRead', isEqualTo: false)
              .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking messages as read: $e');
      }
    }
  }

  // Get unread message count for a conversation
  Stream<int> getUnreadCount(String conversationId) {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create a support conversation
  Future<String?> createSupportConversation() async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return null;

      final conversationId = 'support_$currentUserId';

      // Check if support conversation already exists
      final conversationDoc = await _firestore.collection('conversations').doc(conversationId).get();

      if (!conversationDoc.exists) {
        // Create new support conversation
        await _firestore.collection('conversations').doc(conversationId).set({
          'participants': [currentUserId, 'support'],
          'participantDetails': {
            currentUserId: {
              'uid': currentUserId,
              'name': currentUser?.displayName ?? 'Unknown',
              'email': currentUser?.email ?? '',
            },
            'support': {
              'uid': 'support',
              'name': 'Veteran Support Team',
              'email': 'support@veteransupport.com',
            },
          },
          'lastMessage': 'Welcome! How can we help you today?',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isSupport': true,
        });

        // Add welcome message
        await _firestore.collection('conversations').doc(conversationId).collection('messages').add({
          'senderId': 'support',
          'senderName': 'Veteran Support Team',
          'message': 'Welcome! How can we help you today?',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'messageType': 'text',
        });
      }

      return conversationId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating support conversation: $e');
      }
      return null;
    }
  }
}

// Chat Conversation Model
class ChatConversation {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> participantDetails;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;
  final bool isSupport;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.participants,
    required this.participantDetails,
    required this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
    this.isSupport = false,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantDetails: Map<String, dynamic>.from(data['participantDetails'] ?? {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isSupport: data['isSupport'] ?? false,
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  // Get other participant name
  String getOtherParticipantName(String currentUserId) {
    final otherParticipantId = participants.firstWhere((id) => id != currentUserId, orElse: () => 'unknown');

    if (otherParticipantId == 'support') {
      return 'Veteran Support Team';
    }

    return participantDetails[otherParticipantId]?['name'] ?? 'Unknown User';
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime? timestamp;
  final bool isRead;
  final String messageType;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.timestamp,
    required this.isRead,
    this.messageType = 'text',
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isRead: data['isRead'] ?? false,
      messageType: data['messageType'] ?? 'text',
    );
  }
}
