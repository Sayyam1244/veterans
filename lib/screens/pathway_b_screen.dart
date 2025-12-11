import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class PathwayBScreen extends StatelessWidget {
  const PathwayBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pathway B',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/headphone.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                    colorFilter: const ColorFilter.mode(Color(0xFFE91E63), BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hearing Exposure',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'If you were exposed to loud noises during your service, you may be eligible for hearing loss compensation. This pathway will guide you through the process of filing a claim for hearing loss or tinnitus.',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4),
            ),

            const SizedBox(height: 24),

            // Steps
            Expanded(
              child: ListView(
                children: [
                  _buildStepItem(
                    '1',
                    'File a Claim',
                    'Start by filing a claim for hearing loss or tinnitus with the VA. You can do this online, by mail, or in person at a VA regional office.',
                  ),
                  _buildStepItem(
                    '2',
                    'Schedule a Hearing Screen',
                    'Schedule a hearing screen with a VA audiologist. This will help determine the extent of your hearing loss or tinnitus.',
                  ),
                  _buildStepItem(
                    '3',
                    'Provide Evidence',
                    'Gather evidence to support your claim, including deployment records, training records, and any other documentation that shows your exposure to loud noises.',
                  ),
                  _buildStepItem(
                    '4',
                    'Separation Exam Notes',
                    'Ensure your separation exam notes document any hearing issues, such as tinnitus or hearing loss. This can be crucial evidence in your claim.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // File a claim button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse('https://www.va.gov/disability/how-to-file-claim/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  'File a claim',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
