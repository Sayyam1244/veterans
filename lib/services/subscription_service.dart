import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/stripe_config.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Stripe (call this in main.dart)
  static void initializeStripe() {
    Stripe.publishableKey = StripeConfig.publishableKey;
  }

  // Create payment intent with Stripe
  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String planType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create payment intent via Stripe API
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).round().toString(), // Convert to cents
          'currency': currency,
          'payment_method_types[]': 'card',
          'metadata[user_id]': user.uid,
          'metadata[plan_type]': planType,
          'description': 'Veterans App Subscription - $planType',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'clientSecret': data['client_secret'], 'paymentIntentId': data['id']};
      } else {
        print('Stripe API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  // Create Stripe customer
  Future<String?> createStripeCustomer({required String email, required String name}) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'email': email, 'name': name, 'metadata[user_id]': _auth.currentUser?.uid ?? ''},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        print('Error creating Stripe customer: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating Stripe customer: $e');
      return null;
    }
  }

  // Process subscription payment with Stripe
  Future<bool> processSubscriptionPayment({required String planType, required double amount}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Create payment intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: 'usd',
        planType: planType,
      );

      if (paymentIntentData == null) return false;

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Veterans Support App',
          allowsDelayedPaymentMethods: true,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If payment succeeds, create subscription record
      final startDate = DateTime.now();
      final endDate =
          planType == 'yearly'
              ? startDate.add(const Duration(days: 365))
              : startDate.add(const Duration(days: 30));

      // Get or create Stripe customer
      String? customerId = await _getOrCreateStripeCustomer();
      customerId ??= await createStripeCustomer(
        email: user.email ?? '',
        name: user.displayName ?? 'Veteran User',
      );

      await createSubscription(
        planType: planType,
        amount: amount,
        stripeCustomerId: customerId ?? 'unknown',
        stripeSubscriptionId: paymentIntentData['paymentIntentId'],
        startDate: startDate,
        endDate: endDate,
      );

      return true;
    } on StripeException catch (e) {
      print('Stripe payment error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      print('Error processing payment: $e');
      return false;
    }
  }

  // Get or create Stripe customer ID
  Future<String?> _getOrCreateStripeCustomer() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return data['stripeCustomerId'];
      }
      return null;
    } catch (e) {
      print('Error getting Stripe customer: $e');
      return null;
    }
  }

  // Subscription status stream
  Stream<bool> get subscriptionStatusStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return false;
      final data = doc.data()!;
      final isSubscribed = data['isSubscribed'] ?? false;
      final subscriptionEnd = data['subscriptionEndDate'] as Timestamp?;

      if (isSubscribed && subscriptionEnd != null) {
        return subscriptionEnd.toDate().isAfter(DateTime.now());
      }
      return false;
    });
  }

  // Check current subscription status
  Future<bool> isSubscribed() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final isSubscribed = data['isSubscribed'] ?? false;
      final subscriptionEnd = data['subscriptionEndDate'] as Timestamp?;

      if (isSubscribed && subscriptionEnd != null) {
        return subscriptionEnd.toDate().isAfter(DateTime.now());
      }
      return false;
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }

  // Update subscription status in Firebase
  Future<void> updateSubscriptionStatus({
    required bool isSubscribed,
    DateTime? subscriptionEndDate,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    String? planType,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isSubscribed': isSubscribed,
        'subscriptionEndDate': subscriptionEndDate != null ? Timestamp.fromDate(subscriptionEndDate) : null,
        'stripeCustomerId': stripeCustomerId,
        'stripeSubscriptionId': stripeSubscriptionId,
        'planType': planType,
        'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  // Create subscription record for new payments
  Future<void> createSubscription({
    required String planType,
    required double amount,
    required String stripeCustomerId,
    required String stripeSubscriptionId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Update user subscription status
      await updateSubscriptionStatus(
        isSubscribed: true,
        subscriptionEndDate: endDate,
        stripeCustomerId: stripeCustomerId,
        stripeSubscriptionId: stripeSubscriptionId,
        planType: planType,
      );

      // Create payment record
      await _firestore.collection('payments').add({
        'userId': user.uid,
        'planType': planType,
        'amount': amount,
        'stripeCustomerId': stripeCustomerId,
        'stripeSubscriptionId': stripeSubscriptionId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating subscription: $e');
      rethrow;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get current subscription details
      final subscriptionDetails = await getSubscriptionDetails();
      if (subscriptionDetails != null && subscriptionDetails['stripeSubscriptionId'] != null) {
        // Cancel subscription in Stripe
        final response = await http.delete(
          Uri.parse('https://api.stripe.com/v1/subscriptions/${subscriptionDetails['stripeSubscriptionId']}'),
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );

        if (response.statusCode != 200) {
          print('Error cancelling Stripe subscription: ${response.statusCode} - ${response.body}');
        }
      }

      // Update Firebase record
      await _firestore.collection('users').doc(user.uid).update({
        'isSubscribed': false,
        'subscriptionEndDate': null,
        'stripeSubscriptionId': null,
        'planType': null,
        'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Update payment record status
      final payments =
          await _firestore
              .collection('payments')
              .where('userId', isEqualTo: user.uid)
              .where('status', isEqualTo: 'active')
              .get();

      for (final doc in payments.docs) {
        await doc.reference.update({'status': 'cancelled', 'cancelledAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      print('Error canceling subscription: $e');
      rethrow;
    }
  }

  // Get subscription details
  Future<Map<String, dynamic>?> getSubscriptionDetails() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return {
        'isSubscribed': data['isSubscribed'] ?? false,
        'planType': data['planType'],
        'subscriptionEndDate': data['subscriptionEndDate'],
        'stripeCustomerId': data['stripeCustomerId'],
        'stripeSubscriptionId': data['stripeSubscriptionId'],
      };
    } catch (e) {
      print('Error getting subscription details: $e');
      return null;
    }
  }

  // Verify subscription status with Stripe (for extra security)
  Future<bool> verifySubscriptionWithStripe() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final details = await getSubscriptionDetails();
      if (details == null || details['stripeSubscriptionId'] == null) return false;

      // Check subscription status with Stripe
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/subscriptions/${details['stripeSubscriptionId']}'),
        headers: {'Authorization': 'Bearer ${StripeConfig.secretKey}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        final currentPeriodEnd = DateTime.fromMillisecondsSinceEpoch(data['current_period_end'] * 1000);

        // Update local subscription status if needed
        final isActive =
            (status == 'active' || status == 'trialing') && currentPeriodEnd.isAfter(DateTime.now());

        if (details['isSubscribed'] != isActive) {
          await updateSubscriptionStatus(
            isSubscribed: isActive,
            subscriptionEndDate: currentPeriodEnd,
            stripeCustomerId: details['stripeCustomerId'],
            stripeSubscriptionId: details['stripeSubscriptionId'],
            planType: details['planType'],
          );
        }

        return isActive;
      }
      return false;
    } catch (e) {
      print('Error verifying subscription with Stripe: $e');
      return false;
    }
  }

  // Refresh subscription status (call this periodically or when app starts)
  Future<void> refreshSubscriptionStatus() async {
    try {
      await verifySubscriptionWithStripe();
    } catch (e) {
      print('Error refreshing subscription status: $e');
    }
  }
}
