import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/chat_service.dart';
import '../services/snackbar_service.dart';
import 'chat_screen.dart';

class NearbyUsersScreen extends StatefulWidget {
  const NearbyUsersScreen({super.key});

  @override
  State<NearbyUsersScreen> createState() => _NearbyUsersScreenState();
}

class _NearbyUsersScreenState extends State<NearbyUsersScreen> {
  final LocationService _locationService = LocationService();
  final ChatService _chatService = ChatService();
  double _maxDistance = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nearby Veterans',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showDistanceDialog,
            tooltip: 'Adjust Distance',
          ),
        ],
      ),
      body: Column(
        children: [
          // Distance selector
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Search Distance:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  '${_maxDistance.toInt()} km',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE91E63)),
                ),
              ],
            ),
          ),

          // Nearby users list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _locationService.getNearbyUsersStream(maxDistance: _maxDistance),
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

                final nearbyUsers = snapshot.data ?? [];

                if (nearbyUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_searching, size: 64, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 16),
                        const Text(
                          'No nearby veterans found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expand your search distance or check back later',
                          style: const TextStyle(color: Color(0xFF9CA3AF)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showDistanceDialog,
                          icon: const Icon(Icons.tune),
                          label: const Text('Adjust Distance'),
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
                  itemCount: nearbyUsers.length,
                  itemBuilder: (context, index) {
                    final user = nearbyUsers[index];
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final distance = user['distance'] as double;
    final firstName = user['firstName'] as String;
    final lastName = user['lastName'] as String? ?? '';
    final email = user['email'] as String;

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
          backgroundImage: user['profilePicture'] != null ? NetworkImage(user['profilePicture']) : null,
          child:
              user['profilePicture'] == null
                  ? Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
                  : null,
        ),
        title: Text(
          '$firstName $lastName'.trim(),
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: const TextStyle(color: Color(0xFF757575))),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  '${distance.toStringAsFixed(1)} km away',
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFE91E63)),
          onPressed: () => _startChatWithUser(user),
          tooltip: 'Start Chat',
        ),
      ),
    );
  }

  Future<void> _startChatWithUser(Map<String, dynamic> user) async {
    try {
      final email = user['email'] as String;
      final conversationId = await _chatService.startConversation(email);

      if (conversationId != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(
                  conversationId: conversationId,
                  otherUserName: '${user['firstName']} ${user['lastName']}'.trim(),
                  isSupport: false,
                ),
          ),
        );
      } else if (mounted) {
        SnackBarService.showError(context, 'Failed to start chat');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Error starting chat');
      }
    }
  }

  void _showDistanceDialog() {
    double tempDistance = _maxDistance;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Search Distance'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Find veterans within ${tempDistance.toInt()} km',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Slider(
                        value: tempDistance,
                        min: 1.0,
                        max: 200.0,
                        divisions: 199,
                        activeColor: const Color(0xFFE91E63),
                        inactiveColor: const Color(0xFFE91E63).withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            tempDistance = value;
                          });
                        },
                      ),
                      Text(
                        '${tempDistance.toInt()} km',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        this.setState(() {
                          _maxDistance = tempDistance;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
          ),
    );
  }
}
