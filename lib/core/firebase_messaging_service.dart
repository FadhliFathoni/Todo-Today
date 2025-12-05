import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @pragma('vm:entry-point')
  static Future<void> initialize() async {
    // Skip Firebase Messaging on Windows and Linux (not supported)
    // FCM is supported on Android, iOS, Web, and macOS
    if (Platform.isWindows || Platform.isLinux) {
      print("Firebase Messaging is not supported on Windows/Linux platforms");
      return;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted =
          await androidPlugin?.requestNotificationsPermission();
      print("Notification Permission: $granted");
    }

    // Inisialisasi Firebase
    await Firebase.initializeApp();

    // Minta izin untuk notifikasi (hanya di iOS)
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Dapatkan FCM Token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    try {
      String baseUrl = dotenv.get("BASE_URL");
      var dio = Dio();
      var prefs = await SharedPreferences.getInstance();
      var username = prefs.getString('user');
      print(baseUrl);
      print(username);
      var response = await dio.post(baseUrl + "/register-fcm",
          data: {
            "username": username,
            "token": token,
          },
          options: Options(headers: {
            "Accept": "application/json",
          }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Sukses register token");
      }
    } catch (e) {
      print("Gagal register token: " + e.toString());
    }
    // Konfigurasi notifikasi lokal
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification?.title}");
      showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification Clicked: ${message.notification?.title}");
    });
  }

  static void showLocalNotification(RemoteMessage message) async {
    String title =
        message.notification?.title ?? message.data['title'] ?? 'No Title';
    String body =
        message.notification?.body ?? message.data['body'] ?? 'No Body';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: "@mipmap/launcher_icon");

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }
}
