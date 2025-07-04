import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Resource',
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

                  // Book Marketing Links Section
                  _buildSectionHeader('Book Marketing Links'),
                  SizedBox(height: 16),
                  _buildResourceItem('Barnes & Noble', 'Buy Book & Audio', 'assets/icons/book.svg', () {}),
                  _buildResourceItem('Amazon', 'Buy eBooks', 'assets/icons/book.svg', () {}),

                  SizedBox(height: 24),

                  // VA Hospitals & Disability Filing Section
                  _buildSectionHeader('VA Hospitals & Disability Filing'),
                  SizedBox(height: 16),
                  _buildResourceItem('Map', 'Find locations', 'assets/icons/pin.svg', () {}),
                  _buildResourceItem('Website', 'Visit website', 'assets/icons/globe.svg', () {}),
                  _buildResourceItem('Claims', 'View website', 'assets/icons/doc.svg', () {}),
                  _buildResourceItem('Checklist', 'View website', 'assets/icons/twopage.svg', () {}),

                  SizedBox(height: 24),

                  // Mental Health Resources Section
                  _buildSectionHeader('Mental Health Resources'),
                  SizedBox(height: 16),
                  _buildResourceItem(
                    'Crisis Hotline',
                    'Call crisis hotline',
                    'assets/icons/phone.svg',
                    () {},
                  ),
                  _buildResourceItem(
                    'Free Clinics',
                    'View free clinics',
                    'assets/icons/stethoscope.svg',
                    () {},
                  ),
                  _buildResourceItem(
                    'Telehealth Providers',
                    'View telehealth providers',
                    'assets/icons/screen.svg',
                    () {},
                  ),

                  SizedBox(height: 24),

                  // 24-Hour Nurse Hotline Section
                  _buildSectionHeader('24-Hour Nurse Hotline'),
                  SizedBox(height: 16),
                  _buildResourceItem(
                    'Nurse Hotline',
                    'Call nurse hotline',
                    'assets/icons/phone.svg',
                    () {},
                    showCallIcon: true,
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
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black));
  }

  Widget _buildResourceItem(
    String title,
    String subtitle,
    String iconPath,
    VoidCallback onTap, {
    bool showCallIcon = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 1),
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
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        trailing:
            showCallIcon
                ? Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: Color(0xFFE879A6), shape: BoxShape.circle),
                  child: Icon(Icons.phone, color: Colors.white, size: 16),
                )
                : null,
        onTap: onTap,
      ),
    );
  }
}
