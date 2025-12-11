import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/snackbar_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final bool isSupport;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.isSupport = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when entering chat
    _chatService.markMessagesAsRead(widget.conversationId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Clear the input immediately for better UX
    _messageController.clear();

    try {
      final success = await _chatService.sendMessage(widget.conversationId, message);
      if (!success && mounted) {
        SnackBarService.showError(context, 'Failed to send message');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Error sending message');
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
        ),
        title: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isSupport
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : const Color(0xFFE91E63).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    widget.isSupport
                        ? const Icon(Icons.support_agent, color: Color(0xFF4CAF50), size: 20)
                        : Text(
                          widget.otherUserName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE91E63),
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.isSupport)
                    const Text(
                      'Usually replies instantly',
                      style: TextStyle(color: Color(0xFF757575), fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.isSupport)
            IconButton(
              onPressed: () {
                // TODO: Show support options
                SnackBarService.showInfo(context, 'Support options coming soon');
              },
              icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading messages',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isSupport ? Icons.support_agent : Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.isSupport
                              ? 'Start a conversation with our support team'
                              : 'Start your conversation',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Auto scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == _chatService.currentUser?.uid;

                    return _buildMessageBubble(message, isCurrentUser);
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            // Other user avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    message.senderId == 'support'
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : const Color(0xFFE91E63).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    message.senderId == 'support'
                        ? const Icon(Icons.support_agent, color: Color(0xFF4CAF50), size: 16)
                        : Text(
                          message.senderName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE91E63),
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser ? const Color(0xFFE91E63) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : const Color(0xFF2D2D2D),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white.withOpacity(0.7) : const Color(0xFF9E9E9E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            // Read status indicator
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 16,
              color: message.isRead ? const Color(0xFFE91E63) : const Color(0xFF9E9E9E),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
