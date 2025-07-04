import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
              ),

              const SizedBox(height: 24),
              // Menu Items
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem('Personal Information', Icons.person_outline, () {}),
                    _buildMenuItem('Emergency Contacts', Icons.emergency_outlined, () {}),
                    _buildMenuItem('Settings', Icons.settings_outlined, () {}),
                    _buildMenuItem('Help & Support', Icons.help_outline, () {}),
                    _buildMenuItem('Privacy Policy', Icons.privacy_tip_outlined, () {}),
                    _buildMenuItem('Sign Out', Icons.logout, () {}, isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFE91E63)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.2),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF757575)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDestructive ? Colors.red : const Color(0xFF2D2D2D),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: isDestructive ? Colors.red : const Color(0xFF9E9E9E)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
      ),
    );
  }
}
