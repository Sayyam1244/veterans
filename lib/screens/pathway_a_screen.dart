import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class PathwayAScreen extends StatefulWidget {
  const PathwayAScreen({super.key});

  @override
  State<PathwayAScreen> createState() => _PathwayAScreenState();
}

class _PathwayAScreenState extends State<PathwayAScreen> {
  bool isPreDeployment = true;

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
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPreDeployment = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isPreDeployment ? const Color(0xFFE91E63) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Pre-Deployment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isPreDeployment ? FontWeight.w600 : FontWeight.w500,
                          color: isPreDeployment ? const Color(0xFFE91E63) : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPreDeployment = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !isPreDeployment ? const Color(0xFFE91E63) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Post-Deployment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: !isPreDeployment ? FontWeight.w600 : FontWeight.w500,
                          color: !isPreDeployment ? const Color(0xFFE91E63) : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Content based on selected tab
            if (isPreDeployment) ..._buildPreDeploymentContent() else ..._buildPostDeploymentContent(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPreDeploymentContent() {
    return [
      const Text(
        'Pre-Deployment Steps',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
      ),
      const SizedBox(height: 16),
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
    ];
  }

  List<Widget> _buildPostDeploymentContent() {
    return [
      const Text(
        'Post-Deployment Steps',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
      ),
      const SizedBox(height: 16),
      Expanded(
        child: ListView(
          children: [
            _buildStepItem(
              'assets/icons/globe.svg',
              'File a VA Claim',
              'Use the VA claim link to start your claim.',
            ),
            _buildStepItem(
              'assets/icons/share.svg',
              'Submit Claim',
              'Submit your claim with all necessary documentation.',
            ),
            _buildStepItem(
              'assets/icons/doc.svg',
              'Service Evidence',
              'Provide evidence of your service, such as medical records and service history.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Note: You cannot review rating before providing evidence',
                style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ),
            const SizedBox(height: 8),
            _buildStepItem(
              'assets/icons/star.svg',
              'Review Ratings',
              'Review the ratings and classifications assigned to your claim.',
            ),
            _buildStepItem(
              'assets/icons/clock.svg',
              'Exam Waiting',
              'Wait for an exam, which may not always be face-to-face.',
            ),
            _buildStepItem(
              'assets/icons/mail.svg',
              'Decision Letter',
              'Receive a decision letter regarding your claim.',
            ),
            _buildStepItem(
              'assets/icons/law.svg',
              'Appeal Option',
              'You have the option to appeal the decision if necessary.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Note: Seek professional help for secondary cases.',
                style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
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
    ];
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
