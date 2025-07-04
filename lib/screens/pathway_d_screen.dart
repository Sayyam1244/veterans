import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PathwayDScreen extends StatelessWidget {
  const PathwayDScreen({super.key});

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
          'Pathway D',
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
                        'Toxic Exposure',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'If you\'ve been exposed to hazardous materials or toxins during your military service, it\'s important to document this exposure. This can include:',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                  ),
                  SizedBox(height: 24),

                  // Exposure types
                  _buildExposureItem('Agent Orange'),
                  _buildExposureItem('Asbestos'),
                  _buildExposureItem('Burn Pits'),
                  _buildExposureItem('Chemical and Biological Warfare'),
                  _buildExposureItem('Contaminated Water'),
                  _buildExposureItem('Lead'),
                  _buildExposureItem('Radiation'),
                  _buildExposureItem('Other Chemical Exposures'),

                  SizedBox(height: 24),

                  // Additional information
                  Text(
                    'Document any health issues that may be related to these exposures, including:',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                  ),
                  SizedBox(height: 16),

                  _buildHealthIssueItem('Respiratory problems'),
                  _buildHealthIssueItem('Skin conditions'),
                  _buildHealthIssueItem('Cancer'),
                  _buildHealthIssueItem('Neurological disorders'),
                  _buildHealthIssueItem('Digestive issues'),

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
                onPressed: () {
                  // TODO: Implement file claim functionality
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

  Widget _buildExposureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: Color(0xFFE879A6), shape: BoxShape.circle),
          ),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHealthIssueItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('• ', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Text(text, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
