import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Chat list
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildChatItem(
                  'Veteran Support Org.',
                  'Are you free you today?',
                  'assets/images/explore.png',
                  '2m',
                  false,
                ),
                _buildChatItem(
                  'Ethan Carter',
                  'I\'m feeling worried about...',
                  'assets/images/explore.png',
                  '5m',
                  false,
                ),
                _buildChatItem(
                  'Support Specialist',
                  'Do you to connect you',
                  'assets/images/explore.png',
                  '10m',
                  false,
                ),
                _buildChatItem(
                  'Olivia Bennett',
                  'I\'m feeling worried chatting',
                  'assets/images/explore.png',
                  '15m',
                  false,
                ),
                _buildChatItem(
                  'Support Specialist',
                  'Do you to connect you',
                  'assets/images/explore.png',
                  '20m',
                  false,
                ),
                _buildChatItem(
                  'Noah Thompson',
                  'I\'m feeling worried...',
                  'assets/images/explore.png',
                  '25m',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(String name, String lastMessage, String avatarPath, String time, bool hasNewMessage) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: AssetImage(avatarPath), fit: BoxFit.cover),
            ),
          ),

          SizedBox(width: 12),

          // Chat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    Text(time, style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessage,
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasNewMessage) ...[
                      SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: Color(0xFFE879A6), shape: BoxShape.circle),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
