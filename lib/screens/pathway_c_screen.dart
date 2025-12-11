import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class PathwayCScreen extends StatelessWidget {
  const PathwayCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pathway C',
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
                  // Location icon and title
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/pin.svg',
                        width: 24,
                        height: 24,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Psychological Exposure',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'If you experienced anxiety, depression, or insomnia, it\'s crucial to document these conditions in your separation exam notes when leaving the military. This documentation is essential for supporting any future claims related to psychological conditions. Include your notes include:',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                  ),
                  SizedBox(height: 24),

                  // Anxiety section
                  _buildConditionSection('Anxiety', []),

                  SizedBox(height: 16),

                  // Depression section
                  _buildConditionSection('Depression', []),

                  SizedBox(height: 16),

                  // Insomnia section
                  _buildConditionSection('Insomnia', []),

                  SizedBox(height: 16),

                  // Post Traumatic Stress Disorder section
                  _buildConditionSection('Post Traumatic Stress Disorder (PTSD)', []),

                  SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ),

          // File a claim button
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse('https://www.va.gov/disability/how-to-file-claim/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE879A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: Text(
                  'File a claim',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
        SizedBox(height: 8),
        // Items would go here if there were any in the screenshot
        if (items.isNotEmpty) ...[
          for (String item in items)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            ),
        ],
      ],
    );
  }
}
