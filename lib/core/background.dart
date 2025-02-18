import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/firebase_options.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  bool isRunning = await service.isRunning();
  print("Service is running: $isRunning");

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications for both Android and iOS
  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [
        AndroidForegroundType.location,
        AndroidForegroundType.specialUse
      ],
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Combine Firebase and Firestore logic with the periodic timer
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      var firestore = FirebaseFirestore.instance;

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // Firebase and Firestore interaction
          final prefs = await SharedPreferences.getInstance();
          await prefs.reload();
          var name = prefs.getString('user') ?? 'default_user';
          CollectionReference user = firestore.collection(name);

          // Listen to Firestore updates and trigger notifications
          user.snapshots().listen((QuerySnapshot snapshot) {
            for (QueryDocumentSnapshot doc in snapshot.docs) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if (data['hour'] == TimeOfDay.now().hour.toString() &&
                  data['minute'] == TimeOfDay.now().minute.toString() &&
                  data['status'] != "Done") {
                var androidPlatformChannelSpecifics =
                    const AndroidNotificationDetails(
                  'my_foreground',
                  'MY FOREGROUND SERVICE',
                  importance: Importance.high,
                  priority: Priority.high,
                );
                var platformChannelSpecifics = NotificationDetails(
                    android: androidPlatformChannelSpecifics);
                flutterLocalNotificationsPlugin.show(0, data['title'],
                    "It's time!!!, let's do it😀", platformChannelSpecifics);
                flutterLocalNotificationsPlugin.show(
                  0,
                  data['title'],
                  "It's time!!!, let's do it😀",
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'my_foreground',
                      'MY FOREGROUND SERVICE',
                      ongoing: true,
                      importance: Importance.high,
                      priority: Priority.high,
                    ),
                  ),
                );
              }
              print("MASUK SHOW NOTIF");

              // Reset or delete task at midnight
              if (TimeOfDay.now().hour == 0 && TimeOfDay.now().minute == 0) {
                if (data['daily'] == true) {
                  user.doc(doc.id).update({"status": "Not done yet"});
                } else {
                  user.doc(doc.id).delete();
                }
              }
            }
          });

          // // Optional notification updating every second
          // flutterLocalNotificationsPlugin.show(
          //   888,
          //   'Todo today',
          //   'Awesome ${DateTime.now()}',
          //   const NotificationDetails(
          //     android: AndroidNotificationDetails(
          //       'my_foreground',
          //       'MY FOREGROUND SERVICE',
          //       icon: 'ic_bg_service_small',
          //       ongoing: true,
          //     ),
          //   ),
          // );
        }
      }

      // Device information logging
      final deviceInfo = DeviceInfoPlugin();
      String? device;
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        device = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        device = iosInfo.model;
      }

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "device": device,
        },
      );
    } catch (e) {
      print("Error interacting with Firestore: $e");
    }
  });
}
