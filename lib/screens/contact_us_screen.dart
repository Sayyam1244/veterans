import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Contact Us',
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
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
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

                  SizedBox(height: 24),

                  // Emergency Contacts Section
                  _buildSectionHeader('Emergency Contacts'),
                  SizedBox(height: 16),
                  _buildContactItem(
                    'Mental Health Crisis Hotline',
                    'Call 988-525-3001',
                    'assets/icons/phone.svg',
                    () {},
                  ),
                  _buildContactItem(
                    '24-Hour Nurse Hotline',
                    'Call 985-555-5712',
                    'assets/icons/phone.svg',
                    () {},
                  ),

                  SizedBox(height: 24),

                  // VA Hospitals Contact Info Section
                  _buildSectionHeader('VA Hospitals Contact Info'),
                  SizedBox(height: 16),
                  _buildContactItem(
                    'VA Hospital Locator',
                    'Search nationwide',
                    'assets/icons/pin.svg',
                    () {},
                  ),

                  SizedBox(height: 24),

                  // Veteran Support Organizations Section
                  _buildSectionHeader('Veteran Support Organizations'),
                  SizedBox(height: 16),
                  _buildContactItem(
                    'Veterans of Foreign Wars',
                    'Call 800-555-9998',
                    'assets/icons/phone.svg',
                    () {},
                  ),
                  _buildContactItem(
                    'Disabled American Veterans',
                    'Call 800-555-5878',
                    'assets/icons/phone.svg',
                    () {},
                  ),
                  _buildContactItem('American Legion', 'Call 800-555-3001', 'assets/icons/phone.svg', () {}),

                  SizedBox(height: 24),

                  // Reach Out Section
                  _buildSectionHeader('Reach Out'),
                  SizedBox(height: 8),
                  Text(
                    'If you\'re a veteran or service member seeking assistance, please fill out the form below.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  Text(
                    'We\'ll connect you with the right resources.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),

                  SizedBox(height: 16),

                  // Contact Form
                  _buildTextField('Enter your name'),
                  SizedBox(height: 12),
                  _buildTextField('Enter your email'),
                  SizedBox(height: 12),
                  _buildTextField('Enter your phone number'),
                  SizedBox(height: 12),
                  _buildTextField('Message', maxLines: 4),

                  SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement submit functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE879A6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit',
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

  Widget _buildContactItem(String title, String subtitle, String iconPath, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFFE879A6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: SvgPicture.asset(iconPath, width: 20, height: 20, color: Color(0xFFE879A6))),
        ),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTextField(String hintText, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
