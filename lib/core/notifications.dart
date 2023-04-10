import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_today/main.dart';

class Notifications{
  void sendNotification(String title) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails('your_channel_id', 'your_channel_name', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: true, presentBadge: true, presentAlert: true);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin?.show(0, title, "It's time!!!, let's do it😀", platformChannelSpecifics, payload: 'item x');
  }
}