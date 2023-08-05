import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:slipmarks/helpers/constants.dart';
import 'package:http/http.dart' as http;
import 'package:slipmarks/services/auth_service.dart';

class MessagingService {
  static String? fcmToken;
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Retrieving the FCM token
      fcmToken = await _fcm.getToken();
      print('fcmToken: $fcmToken');

      // Read the old token from secure storage and compare it with the new one
      // If its different, update the token on the server
      final storedFcmToken = await secureStorage.read(key: FCM_TOKEN_KEY);
      if (fcmToken != storedFcmToken) {
        await secureStorage.write(key: FCM_TOKEN_KEY, value: fcmToken);
        print("fcm token is new, sending it to server");

        if (fcmToken != null) {
          sendTokenToServer(fcmToken!);
        }
      } else {
        debugPrint("fcm token was the same as old one, not updating to server");
      }

      sendTokenToServer(fcmToken ?? "");

      // Handling background messages using the specified handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Listening for incoming messages while the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Message title: ${message.notification!.title.toString()}');

        if (message.notification != null) {
          if (message.notification!.title != null &&
              message.notification!.body != null) {
            final notificationData = message.data;
            debugPrint('Message data: $notificationData');

            // TODO: show notification in app or open link in browser
          }
        }
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> sendTokenToServer(String pushToken) async {
    var (id, model) = await getDeviceModelAndUniqueId();
    print("Device id: $id");
    print("Device model: $model");
    print("Push token: $fcmToken");
    print("Platform: ${Platform.operatingSystem.toUpperCase()}");

    try {
      final accessToken = AuthService.instance.accessToken;
      final url = Uri.parse('$SERVER_HOST/devices');
      await http.put(url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "device_id": id,
            "device_name": model,
            "push_token": pushToken,
            "platform": Platform.operatingSystem.toUpperCase(),
          }));
    } catch (e) {
      print('Error creating device: $e');
    }
  }

  Future<(String?, String)> getDeviceModelAndUniqueId() async {
    late String? id;
    late String model;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor;
      model = iosInfo.utsname.machine;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      const androidIdPlugin = AndroidId();
      final String? androidId = await androidIdPlugin.getId();

      id = androidId;
      model = androidInfo.model;
    } else {
      id = 'unknown';
      model = 'unknown';
    }

    return (id, model);
  }
}

// Handler for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message: ${message.notification!.title}');
}
