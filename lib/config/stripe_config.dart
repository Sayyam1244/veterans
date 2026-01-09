import 'dart:developer';

import 'stripe_remote_config.dart';

class StripeConfig {
  static String publishableKey = '';
  static String secretKey = '';

  static const bool isTestMode = false;
  static const Map<String, String> planPrices = {'monthly': '25.00', 'yearly': '299.99'};
  static const String currency = 'usd';

  static Future<void> loadKeysFromRemoteConfig() async {
    final keys = await StripeRemoteConfig.fetchStripeKeys();
    log('Fetched Stripe keys from Remote Config: $keys');
    if (keys['publishableKey']?.isNotEmpty ?? false) publishableKey = keys['publishableKey']!;
    if (keys['secretKey']?.isNotEmpty ?? false) secretKey = keys['secretKey']!;
  }
}
