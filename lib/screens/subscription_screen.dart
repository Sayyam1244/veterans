import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/subscription_service.dart';
import '../services/snackbar_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String _selectedPlan = 'monthly';

  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'id': 'monthly',
      'title': 'Monthly Premium',
      'price': '25.00',
      'period': 'month',
      'description': 'Full access to all resources and features',
      'features': [
        'Complete resource directory',
        'Crisis hotlines and emergency services',
        'Legal aid resources',
        'Housing and food assistance',
        'Veteran services directory',
        'Disability advocacy resources',
        'Priority customer support',
        'Offline access to resources',
      ],
    },
    {
      'id': 'yearly',
      'title': 'Yearly Premium',
      'price': '199.99',
      'period': 'year',
      'description': 'Save 16% with annual billing',
      'originalPrice': '239.88',
      'features': [
        'Everything in Monthly Premium',
        'Save \$40 per year',
        'Priority feature updates',
        'Exclusive premium content',
        'Advanced search filters',
        'Export resources to PDF',
        'Calendar integration',
        'Dedicated support channel',
      ],
    },
  ];

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
          'Premium Access',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFE879A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/icons/star.svg', width: 48, height: 48, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        'Unlock Full Access',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get unlimited access to all veteran resources, crisis support, and premium features',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white, height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Free vs Premium Comparison
                _buildComparisonSection(),

                const SizedBox(height: 32),

                // Subscription Plans
                const Text(
                  'Choose Your Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 16),

                ..._subscriptionPlans.map((plan) => _buildPlanCard(plan)),

                const SizedBox(height: 24),

                // Subscribe Button
                _buildSubscribeButton(),

                const SizedBox(height: 16),

                // Terms and Privacy
                _buildTermsAndPrivacy(),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
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
                const Expanded(
                  child: Text('Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Features comparison
          _buildComparisonRow('Crisis hotlines (limited)', true, true),
          _buildComparisonRow('Complete resource directory', false, true),
          _buildComparisonRow('Legal aid resources', false, true),
          _buildComparisonRow('Housing assistance', false, true),
          _buildComparisonRow('Veterans services', false, true),
          _buildComparisonRow('Disability advocacy', false, true),
          _buildComparisonRow('Priority support', false, true),
          _buildComparisonRow('Offline access', false, true),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, bool freeHas, bool premiumHas) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 14))),
          SizedBox(
            width: 80,
            child: Icon(
              freeHas ? Icons.check : Icons.close,
              color: freeHas ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          SizedBox(
            width: 80,
            child: Icon(
              premiumHas ? Icons.check : Icons.close,
              color: premiumHas ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == plan['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFFE91E63).withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(plan['description'], style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (plan['originalPrice'] != null)
                      Text(
                        '\$${plan['originalPrice']}',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      '\$${plan['price']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Text(
                      'per ${plan['period']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            if (plan['id'] == 'yearly')
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  'SAVE 16%',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16),
            ...plan['features']
                .map<Widget>(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFFE91E63), size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final selectedPlan = _subscriptionPlans.firstWhere((plan) => plan['id'] == _selectedPlan);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleSubscription(selectedPlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Subscribe for \$${selectedPlan['price']}/${selectedPlan['period']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Column(
      children: [
        const Text(
          'By subscribing, you agree to our Terms of Service and Privacy Policy. Your subscription will automatically renew unless cancelled.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Open Terms of Service
              },
              child: const Text('Terms of Service', style: TextStyle(fontSize: 12, color: Color(0xFFE91E63))),
            ),
            const Text(' • ', style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () {
                // Open Privacy Policy
              },
              child: const Text('Privacy Policy', style: TextStyle(fontSize: 12, color: Color(0xFFE91E63))),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSubscription(Map<String, dynamic> plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Process the subscription payment
      final success = await _subscriptionService.processSubscriptionPayment(
        planType: plan['id'],
        amount: double.parse(plan['price']),
      );

      if (success) {
        if (mounted) {
          SnackBarService.showSuccess(context, 'Subscription activated successfully! Welcome to Premium!');
          Navigator.pop(context, true); // Return true to indicate successful subscription
        }
      } else {
        if (mounted) {
          SnackBarService.showError(context, 'Payment was cancelled or failed. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred. Please try again.';

        // Handle specific error types for better user experience
        if (e.toString().contains('cancelled')) {
          errorMessage = 'Payment was cancelled.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (e.toString().contains('card')) {
          errorMessage = 'Card error. Please check your payment information.';
        }

        SnackBarService.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
