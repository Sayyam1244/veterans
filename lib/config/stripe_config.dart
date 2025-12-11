class StripeConfig {
  // Production Stripe Keys
  static const String publishableKey =
      'pk_live_51SG1yGP5mHW8t9OZfN7o1XLnK78qLQmA0Hd1zp2ChK4LNb6ruYeaSmXwnU88VrlEm8CyhuVb8WIeYDHIrEvjCVY500CXUtn33L';
  static const String secretKey =
      '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';

  // Test mode - set to false for production
  static const bool isTestMode = false;

  // Subscription plans
  static const Map<String, String> planPrices = {'monthly': '19.99', 'yearly': '199.99'};

  // Currency
  static const String currency = 'usd';
}
