import 'package:firebase_remote_config/firebase_remote_config.dart';

class StripeRemoteConfig {
  static Future<Map<String, String>> fetchStripeKeys() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final publishableKey = remoteConfig.getString('stripe_publishable_key');
    final secretKey = remoteConfig.getString('secret_key');
    return {'publishableKey': publishableKey, 'secretKey': secretKey};
  }
}
