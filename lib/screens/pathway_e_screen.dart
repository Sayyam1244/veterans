import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PathwayEScreen extends StatelessWidget {
  const PathwayEScreen({super.key});

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
          'Pathway E',
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
                        'TBI',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Traumatic Brain Injury (TBI) can result from various incidents during military service. It\'s important to document any head injuries and related symptoms. Common causes include:',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                  ),
                  SizedBox(height: 24),

                  // TBI causes
                  _buildTBIItem('Blast injuries from IEDs or explosions'),
                  _buildTBIItem('Vehicle accidents'),
                  _buildTBIItem('Falls'),
                  _buildTBIItem('Sports injuries'),
                  _buildTBIItem('Combat-related injuries'),
                  _buildTBIItem('Training accidents'),

                  SizedBox(height: 24),

                  // Symptoms section
                  Text(
                    'Symptoms to document may include:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  SizedBox(height: 16),

                  _buildSymptomItem('Headaches'),
                  _buildSymptomItem('Memory problems'),
                  _buildSymptomItem('Difficulty concentrating'),
                  _buildSymptomItem('Dizziness'),
                  _buildSymptomItem('Sleep disturbances'),
                  _buildSymptomItem('Mood changes'),
                  _buildSymptomItem('Balance problems'),
                  _buildSymptomItem('Sensitivity to light or noise'),

                  SizedBox(height: 24),

                  // Additional note
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Note: TBI symptoms may not appear immediately and can develop over time. It\'s important to report any head injuries, even if symptoms seem minor initially.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

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

  Widget _buildTBIItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: Color(0xFFE879A6), shape: BoxShape.circle),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomItem(String text) {
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
