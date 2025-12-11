import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/subscription_service.dart';
import 'subscription_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isSubscribed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final isSubscribed = await _subscriptionService.isSubscribed();
      setState(() {
        _isSubscribed = isSubscribed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isSubscribed = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))),
        ),
      );
    }

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

                  // Premium Badge for non-subscribers
                  if (!_isSubscribed) _buildPremiumBanner(),

                  // Crisis & Emergency Services Section (Always available)
                  _buildSectionHeader('Crisis & Emergency Services'),
                  SizedBox(height: 16),
                  _buildResourceItem(
                    'Suicide Prevention Service',
                    '24-HR Suicide Prevention Phone Service\n1-866-260-8000',
                    'assets/icons/phone.svg',
                    () {},
                    showCallIcon: true,
                  ),
                  _buildResourceItem(
                    'National Suicide Prevention Lifeline',
                    'National Suicide Prevention Lifeline\n1-800-273-8255',
                    'assets/icons/phone.svg',
                    () {},
                    showCallIcon: true,
                  ),

                  SizedBox(height: 24),

                  // Premium Content Sections
                  if (_isSubscribed) ...[
                    // Health & Support Services Section
                    _buildSectionHeader('Health & Support Services'),
                    SizedBox(height: 16),
                    _buildResourceItem(
                      'Collin County Health Care Services',
                      'WIC/Indigent Health/Food Stamps\n1-972-548-5500',
                      'assets/icons/stethoscope.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'LifePath/MHMR',
                      'https://www.collincountytx.gov\n1-972-562-0080',
                      'assets/icons/heart.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'QMB or Medicaid',
                      'Qualified Medicare Beneficiary\n1-214-750-4619',
                      'assets/icons/sheildCheck.svg',
                      () {},
                      showCallIcon: true,
                    ),

                    SizedBox(height: 24),

                    // Veterans Services Section
                    _buildSectionHeader('Veterans Services'),
                    SizedBox(height: 16),
                    _buildResourceItem(
                      'Collin County Veterans Services',
                      'https://www.collincountytx.gov/veterans\n1-972-881-3060',
                      'assets/icons/star.svg',
                      () {},
                      showCallIcon: true,
                    ),

                    SizedBox(height: 24),

                    // Housing & Food Services Section
                    _buildSectionHeader('Housing & Food Services'),
                    SizedBox(height: 16),
                    _buildResourceItem(
                      'Plano Housing',
                      'Housing Services\n1-972-423-4928',
                      'assets/icons/home.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'Collin County Food Pantry',
                      'Emergency Food\n1-972-547-4404',
                      'assets/icons/heart.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'Samaritan Inn',
                      'Short-term Food and Shelter\n1-972-542-5302',
                      'assets/icons/home.svg',
                      () {},
                      showCallIcon: true,
                    ),

                    SizedBox(height: 24),

                    // Legal Services Section
                    _buildSectionHeader('Legal Services'),
                    SizedBox(height: 16),
                    _buildResourceItem(
                      'Legal Aid of Northwest Texas',
                      'www.lanwt.org\n1-800-906-3045',
                      'assets/icons/law.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'Legal Hospice of Texas',
                      'www.legalhospice.org\n1-214-521-6622',
                      'assets/icons/law.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'State Bar of Texas',
                      'www.texasbar.com\n1-800-252-9690',
                      'assets/icons/law.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'Texas Legal Services Center',
                      'www.tlsc.org\n1-800-622-2520',
                      'assets/icons/law.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'American Bar Association',
                      'www.americanbar.org\n1-800-285-2221',
                      'assets/icons/law.svg',
                      () {},
                      showCallIcon: true,
                    ),

                    SizedBox(height: 24),

                    // Disability & Advocacy Services Section
                    _buildSectionHeader('Disability & Advocacy Services'),
                    SizedBox(height: 16),
                    _buildResourceItem(
                      'National Association of Disability Representatives',
                      'www.nadr.org\n1-202-822-2155',
                      'assets/icons/sheildCheck.svg',
                      () {},
                      showCallIcon: true,
                    ),
                    _buildResourceItem(
                      'National Organization of Social Security Claimants',
                      'www.nosscr.org\n1-845-682-1880',
                      'assets/icons/sheildCheck.svg',
                      () {},
                      showCallIcon: true,
                    ),

                    SizedBox(height: 24),

                    // Additional Services Section
                    _buildSectionHeader('Additional Services'),
                    SizedBox(height: 16),
                    _buildResourceItem(
                      'Collin County Courthouse',
                      'Metro #--Plano/Wylie is 972 424-1460\n1-972-548-4100',
                      'assets/icons/law.svg',
                      () {},
                      showCallIcon: true,
                    ),
                  ] else ...[
                    // Premium Content Preview for non-subscribers
                    _buildPremiumSection('Health & Support Services', [
                      'Collin County Health Care Services',
                      'LifePath/MHMR',
                      'QMB or Medicaid',
                    ]),
                    _buildPremiumSection('Veterans Services', [
                      'Collin County Veterans Services',
                      'VA Disability Filing',
                    ]),
                    _buildPremiumSection('Housing & Food Services', [
                      'Plano Housing',
                      'Collin County Food Pantry',
                      'Samaritan Inn',
                    ]),
                    _buildPremiumSection('Legal Services', [
                      'Legal Aid of Northwest Texas',
                      'Legal Hospice of Texas',
                      'State Bar of Texas',
                      'Texas Legal Services Center',
                      'American Bar Association',
                    ]),
                    _buildPremiumSection('Disability & Advocacy Services', [
                      'National Association of Disability Representatives',
                      'National Organization of Social Security Claimants',
                    ]),
                  ],

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
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFFE879A6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: SvgPicture.asset(iconPath, width: 20, height: 20, color: Color(0xFFE879A6))),
        ),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            showCallIcon
                ? Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Color(0xFFE879A6), shape: BoxShape.circle),
                  child: Icon(Icons.phone, color: Colors.white, size: 18),
                )
                : Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFE879A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔓 Unlock All Resources',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get access to complete veteran resources including legal aid, housing assistance, and more.',
                  style: TextStyle(fontSize: 14, color: Colors.white, height: 1.3),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                    );
                    if (result == true) {
                      _checkSubscriptionStatus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Upgrade Now - \$19.99/month',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SvgPicture.asset('assets/icons/star.svg', width: 48, height: 48, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(String title, List<String> resources) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Blurred content
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...resources
                    .take(3)
                    .map(
                      (resource) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.lock, color: Colors.grey, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resource,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text(
                                    'Phone number & details hidden',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (resources.length > 3)
                  Text(
                    '+${resources.length - 3} more resources',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                      );
                      if (result == true) {
                        _checkSubscriptionStatus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Unlock This Section - \$19.99/month',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
