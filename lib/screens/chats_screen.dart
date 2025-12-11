import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/snackbar_service.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startNewChat() async {
    final result = await showDialog<String>(context: context, builder: (context) => _buildNewChatDialog());

    if (result != null && result.isNotEmpty) {
      try {
        final conversationId = await _chatService.startConversation(result);
        if (conversationId != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ChatScreen(conversationId: conversationId, otherUserName: result, isSupport: false),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(context, 'Error starting chat');
        }
      }
    }
  }

  Widget _buildNewChatDialog() {
    final TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: const Text('Start New Chat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter the email address of the person you want to chat with:'),
          const SizedBox(height: 16),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final email = emailController.text.trim();
            if (email.isNotEmpty) {
              Navigator.of(context).pop(email);
            }
          },
          child: const Text('Start Chat'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _startNewChat,
            icon: const Icon(Icons.add_comment, color: Color(0xFFE91E63)),
            tooltip: 'Start New Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search conversations',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: InkWell(
              onTap: _startNewChat,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                      child: const Icon(Icons.add_comment, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start New Chat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Connect with other veterans and community',
                            style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF4CAF50)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatConversation>>(
              stream: _chatService.getConversations(),
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
                        const Icon(Icons.error_outline, size: 64, color: Color(0xFF757575)),
                        const SizedBox(height: 16),
                        const Text(
                          'Something went wrong',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Color(0xFF757575)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final conversations = snapshot.data ?? [];
                final filteredConversations =
                    _searchQuery.isEmpty
                        ? conversations
                        : conversations.where((conv) {
                          final otherUserName = conv.getOtherParticipantName(
                            _chatService.currentUser?.uid ?? '',
                          );
                          return otherUserName.toLowerCase().contains(_searchQuery) ||
                              conv.lastMessage.toLowerCase().contains(_searchQuery);
                        }).toList();

                if (filteredConversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 64, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 16),
                        const Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start a new conversation to connect with others',
                          style: TextStyle(color: Color(0xFF9CA3AF)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _startNewChat,
                          icon: const Icon(Icons.add_comment),
                          label: const Text('Start New Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = filteredConversations[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE91E63),
                          child: Text(() {
                            final otherUserName = conversation.getOtherParticipantName(
                              _chatService.currentUser?.uid ?? '',
                            );
                            return otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?';
                          }(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(
                          conversation.getOtherParticipantName(_chatService.currentUser?.uid ?? ''),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
                        ),
                        subtitle: Text(
                          conversation.lastMessage.isNotEmpty
                              ? conversation.lastMessage
                              : 'Tap to start chatting',
                          style: TextStyle(
                            color:
                                conversation.lastMessage.isNotEmpty
                                    ? const Color(0xFF757575)
                                    : const Color(0xFF9CA3AF),
                            fontStyle:
                                conversation.lastMessage.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatScreen(
                                    conversationId: conversation.id,
                                    otherUserName: conversation.getOtherParticipantName(
                                      _chatService.currentUser?.uid ?? '',
                                    ),
                                    isSupport: false,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
