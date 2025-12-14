import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';
import 'services/scheduled_notification_manager.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('Initializing Firebase');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('Firebase initialized');
  // Initialize Stripe
  SubscriptionService.initializeStripe();
  log('Stripe initialized');
  // Initialize notification service
  await NotificationService().initialize();
  log('Notification service initialized');
  // Start scheduled notification manager
  ScheduledNotificationManager().start();
  log('Scheduled notification manager started');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veterans Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (FirebaseAuth.instance.currentUser != null) {
          return const MainNavigationScreen();
        }

        // If user is not signed in, show welcome screen
        return const WelcomeScreen();
      },
    );
  }
}
