// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/views/History.dart';
import 'package:todo_today/views/Home.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Color PRIMARY_COLOR = Color.fromARGB(255, 255, 142, 61);
Color BG_COLOR = Color.fromARGB(255, 239, 240, 243);

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await AndroidAlarmManager.initialize();
  // final int periodicID = 0;
  // await AndroidAlarmManager.periodic(const Duration(hours: 24), periodicID, daily, startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0));
  runApp(MyApp());
}

// void daily(CollectionReference user, String id) async {
//   user.doc(id).update({"status": "Not done yet"});
//   var androidPlatformChannelSpecifics = const AndroidNotificationDetails('your_channel_id', 'your_channel_name', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
//   // var iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: true, presentBadge: true, presentAlert: true);
//   var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin?.show(0, "Reset", 'Todo telah reset, ayo buat list😀', platformChannelSpecifics, payload: 'item x');
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TimeOfDay time = TimeOfDay.now();
  double width(BuildContext context) => MediaQuery.of(context).size.width;
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  int currentIndex = 0;
  Timer? _timer;
  bool isDaily = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void startTimer(int hour, int minute, String title) {
    DateTime now = DateTime.now();
    DateTime timerEnd = DateTime(now.year, now.month, now.day, hour, minute, 0);
    Duration duration = timerEnd.difference(now);

    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(duration, () {
      _sendNotification(title);
      print("This is notification");
    });
  }

  void notDaily(CollectionReference user, String id) {
    DateTime now = DateTime.now();
    DateTime timerEnd = DateTime(now.year, now.month, now.day, 0, 0, 0);
    Duration duration = timerEnd.difference(now);

    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(duration, () {
      user.doc(id).delete();
      print("This is notification");
    });
  }

  void _sendNotification(String title) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails('your_channel_id', 'your_channel_name', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: true, presentBadge: true, presentAlert: true);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, "It's time!!!, let's do it😀", platformChannelSpecifics, payload: 'item x');
  }

  Widget? buildBody() {
    switch (currentIndex) {
      case 0:
        return Home();
      case 1:
        return History();
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection("user1");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "TODO TODAY!!!",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            currentIndex = value;
            setState(() {});
          },
          selectedItemColor: PRIMARY_COLOR,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          ]),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    content: Container(
                      width: width(context) * 0.7,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Text(
                            "Create",
                            style: TextStyle(color: PRIMARY_COLOR, fontWeight: FontWeight.w500, fontSize: 16),
                          )),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 55,
                            child: TextField(
                              controller: title,
                              maxLength: 30,
                              cursorColor: PRIMARY_COLOR,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                hintText: "Title",
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PRIMARY_COLOR)),
                              ),
                            ),
                          ),
                          Container(
                            height: 55,
                            child: TextField(
                              controller: description,
                              maxLength: 50,
                              cursorColor: PRIMARY_COLOR,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                hintText: "Description",
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PRIMARY_COLOR)),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: Row(
                              children: [
                                Container(
                                  child: Text("${time.hour}"),
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                                ),
                                Text(":"),
                                Container(
                                  child: Text("${time.minute}"),
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                                )
                              ],
                            ),
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(context: context, initialTime: time);
                              if (picked != null) {
                                setState(() {
                                  time = picked;
                                });
                              }
                            },
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isDaily,
                                onChanged: (value) {
                                  setState(() {
                                    isDaily = !isDaily;
                                  });
                                },
                              ),
                              Text("Everyday"),
                            ],
                          )
                        ],
                      ),
                    ),
                    actions: [
                      Container(
                          margin: EdgeInsets.only(right: 14),
                          height: 28,
                          width: 81,
                          child: ElevatedButton(
                            onPressed: () async {
                              // var newdata = await
                              user.add({
                                "title": title.text,
                                "description": description.text,
                                "date": DateTime.now().toString(),
                                "time": "${time.hour}:${time.minute}",
                                "status": "Not done yet",
                                "daily": isDaily
                              });
                              startTimer(time.hour, time.minute, title.text);
                              // if (isDaily == false) {
                              //   notDaily(user, newdata.id);
                              // }
                              // else {

                              // }
                              Navigator.pop(context);
                            },
                            child: Text("Create"),
                            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
                          )),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Image.asset("assets/icons/plus.png"),
      ),
    );
  }
}
