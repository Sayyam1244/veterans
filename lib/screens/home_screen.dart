import 'package:flutter/material.dart';
import 'pathway_a_screen.dart';
import 'pathway_b_screen.dart';
import 'pathway_c_screen.dart';
import 'pathway_d_screen.dart';
import 'pathway_e_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _updateUserLocation();
  }

  Future<void> _updateUserLocation() async {
    try {
      await _locationService.updateUserLocation();
    } catch (e) {
      // Silently handle location errors - don't disrupt user experience
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Replace with your logo asset
                    width: 140,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                    child: StreamBuilder<int>(
                      stream: _notificationService.getUnreadNotificationsCount(),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        return Stack(
                          children: [
                            const Icon(Icons.notifications_outlined, size: 24),
                            if (unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE91E63),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Select a pathway',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
              ),

              const SizedBox(height: 20),

              // Pathway Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildPathwayCard(
                      context,
                      'Pre/Post Deployment VA Claim Process',
                      'Learn about the VA claim process before and after deployment.',
                      'Pathway A',
                      'assets/images/homeImage1.png',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PathwayAScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildPathwayCard(
                      context,
                      'Hearing Exposure',
                      'Understand the risks of hearing exposure and how to protect your hearing.',
                      'Pathway B',
                      'assets/images/homeImage3.png',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PathwayBScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildPathwayCard(
                      context,
                      'Psychological Exposure',
                      'Learn about the psychological effects of deployment and how to cope.',
                      'Pathway C',
                      'assets/images/homeImage4.png',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PathwayCScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildPathwayCard(
                      context,
                      'Toxic Exposure',
                      'Understand the risks of toxic exposure and how to seek care.',
                      'Pathway D',
                      'assets/images/homeImage1.png',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PathwayDScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildPathwayCard(
                      context,
                      'TBI',
                      'Resources for traumatic brain injury assessment and support.',
                      'Pathway E',
                      'assets/images/homeImage2.png',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PathwayEScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathwayCard(
    BuildContext context,
    String title,
    String description,
    String pathway,
    String imagePath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      pathway,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Image
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
