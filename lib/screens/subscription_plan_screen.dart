import 'package:flutter/material.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  String selectedPlan = 'monthly';

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
          'Subscription Plan',
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
                  // Header
                  Text(
                    'Choose a plan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Select a subscription plan that best fits your needs. All plans include access to our veteran support resources, mental health services, and community network.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                  ),

                  SizedBox(height: 32),

                  // Subscription Benefits
                  Text(
                    'Subscription Benefits',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  ),

                  SizedBox(height: 16),

                  _buildBenefitItem('24-Hour Mental Health Hotline Access (24/365)'),
                  _buildBenefitItem('Emergency Mental Health Resources'),
                  _buildBenefitItem('Access to dedicated Veteran support ser...'),
                  _buildBenefitItem('Regular updates and new features'),

                  SizedBox(height: 32),

                  // Monthly Plan
                  Text(
                    'Monthly Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  ),

                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => setState(() => selectedPlan = 'monthly'),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: selectedPlan == 'monthly' ? Color(0xFFE879A6).withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedPlan == 'monthly' ? Color(0xFFE879A6) : Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedPlan == 'monthly' ? Color(0xFFE879A6) : Color(0xFFD1D5DB),
                                width: 2,
                              ),
                            ),
                            child:
                                selectedPlan == 'monthly'
                                    ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE879A6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$299',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                Text('/month', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Subscribe Now Button for Monthly
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          selectedPlan == 'monthly'
                              ? () {
                                // TODO: Implement monthly subscription
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPlan == 'monthly' ? Color(0xFFE879A6) : Color(0xFFE5E7EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Subscribe Now',
                        style: TextStyle(
                          color: selectedPlan == 'monthly' ? Colors.white : Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Annual Plan
                  Text(
                    'Annual Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  ),

                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => setState(() => selectedPlan = 'annual'),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: selectedPlan == 'annual' ? Color(0xFFE879A6).withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedPlan == 'annual' ? Color(0xFFE879A6) : Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedPlan == 'annual' ? Color(0xFFE879A6) : Color(0xFFD1D5DB),
                                width: 2,
                              ),
                            ),
                            child:
                                selectedPlan == 'annual'
                                    ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE879A6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '\$2999',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF3B82F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Best Value',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text('/year', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Subscribe Now Button for Annual
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          selectedPlan == 'annual'
                              ? () {
                                // TODO: Implement annual subscription
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPlan == 'annual' ? Color(0xFFE879A6) : Color(0xFFE5E7EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Subscribe Now',
                        style: TextStyle(
                          color: selectedPlan == 'annual' ? Colors.white : Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: Color(0xFFE879A6), shape: BoxShape.circle),
            child: Icon(Icons.check, color: Colors.white, size: 12),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Color(0xFF374151)))),
        ],
      ),
    );
  }
}
