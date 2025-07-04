import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:veteranns/screens/home_screen.dart';
import 'resources_screen.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ResourcesScreen(),
    const ChatsScreen(),
    const SettingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem('assets/icons/home.svg', 'Home', 0),
            _buildBottomNavItem('assets/icons/page.svg', 'Resources', 1),
            _buildBottomNavItem('assets/icons/chat.svg', 'Chat', 2),
            _buildBottomNavItem('assets/icons/setting.svg', 'Settings', 3),
            _buildBottomNavItem('assets/icons/profile.svg', 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(String iconPath, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            color: isSelected ? Color(0xFFE879A6) : Color(0xFF9CA3AF),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: isSelected ? Color(0xFFE879A6) : Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}
