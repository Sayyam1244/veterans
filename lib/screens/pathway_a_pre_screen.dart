import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PathwayAPreScreen extends StatelessWidget {
  const PathwayAPreScreen({super.key});

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
          'Pathway A',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Comprehensive Injury Documentation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
            ),

            const SizedBox(height: 12),

            // Description
            const Text(
              'Documenting injuries and health conditions is crucial for veterans, both before and after deployment. This ensures accurate records for future claims and support.',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4),
            ),

            const SizedBox(height: 24),

            // Pre-Deployment and Post-Deployment tabs
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE91E63), width: 2)),
                    ),
                    child: const Text(
                      'Pre-Deployment',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFE91E63)),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      'Post-Deployment',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF9E9E9E)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pre-Deployment Steps
            const Text(
              'Pre-Deployment Steps',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
            ),

            const SizedBox(height: 16),

            // Steps list
            Expanded(
              child: ListView(
                children: [
                  _buildStepItem(
                    'assets/icons/stethoscope.svg',
                    'Medical Evaluation',
                    'Schedule a comprehensive medical assessment before deployment.',
                  ),
                  _buildStepItem(
                    'assets/icons/doc.svg',
                    'Accurate Records',
                    'Ensure all injuries, symptoms, and treatments are accurately recorded in your medical file.',
                  ),
                  _buildStepItem(
                    'assets/icons/copy.svg',
                    'Obtain Copies',
                    'Obtain copies of the medical documents, including diagnoses, reports, and treatment records.',
                  ),
                  _buildStepItem(
                    'assets/icons/pencil.svg',
                    'Personal Log',
                    'Keep a personal log of any injuries, symptoms, and treatments received during service.',
                  ),
                  _buildStepItem(
                    'assets/icons/page.svg',
                    'Gather Your Evidence (Claim Filing)',
                    'The process of gathering should be before filing the claim and gathering evidence.',
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
                onPressed: () {
                  // Handle file a claim
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

  Widget _buildStepItem(String iconPath, String title, String description) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Color(0xFFE91E63), BlendMode.srcIn),
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
