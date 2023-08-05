import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingService {
  static String? fcmToken;
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;

  MessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init(BuildContext context) async {
    // Requesting permission for notifications
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted notifications permission: ${settings.authorizationStatus}');

    // Retrieving the FCM token
    fcmToken = await _fcm.getToken();
    print('fcmToken: $fcmToken');

}

