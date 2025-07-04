import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Setting',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Settings Section
                  _buildSectionHeader('Personal Settings'),
                  SizedBox(height: 16),
                  _buildSettingItem('Change Password', Icons.chevron_right, () {}),
                  _buildSettingItem('Notification Preferences', Icons.chevron_right, () {}),

                  SizedBox(height: 32),

                  // Discovery Settings Section
                  _buildSectionHeader('Discovery Settings'),
                  SizedBox(height: 16),
                  _buildSettingItem(
                    'Device Discovery',
                    Icons.chevron_right,
                    () {},
                    subtitle: 'Enable or disable device discovery',
                  ),
                  _buildSettingItem(
                    'Distance',
                    Icons.chevron_right,
                    () {},
                    subtitle: 'Set a maximum distance for device discovery',
                  ),
                  _buildSettingItem(
                    'Age Range',
                    Icons.chevron_right,
                    () {},
                    subtitle: 'Set the age range for device discovery',
                  ),
                  _buildSettingItem(
                    'Gender',
                    Icons.chevron_right,
                    () {},
                    subtitle: 'Set the gender for device discovery',
                  ),

                  SizedBox(height: 32),

                  // Privacy Settings Section
                  _buildSectionHeader('Privacy Settings'),
                  SizedBox(height: 16),
                  _buildSettingItem(
                    'Profile Visibility',
                    Icons.chevron_right,
                    () {},
                    subtitle: 'Control who can see your profile',
                  ),
                  _buildSettingItem(
                    'Post Visibility',
                    Icons.chevron_right,
                    () {},
                    subtitle: 'Control who can see your posts',
                  ),

                  SizedBox(height: 32),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save changes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE879A6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black));
  }

  Widget _buildSettingItem(String title, IconData trailingIcon, VoidCallback onTap, {String? subtitle}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black)),
        subtitle:
            subtitle != null
                ? Text(subtitle, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))
                : null,
        trailing: Icon(trailingIcon, color: Color(0xFF9CA3AF), size: 20),
        onTap: onTap,
      ),
    );
  }
}
