// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/core/notifications.dart';
import 'package:todo_today/views/History.dart';
import 'package:todo_today/views/Home.dart';
import 'package:workmanager/workmanager.dart';
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
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(MyApp());
}

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask = "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask = "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        Notifications().sendNotification("Tes");
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        break;
      case failedTaskKey:
        print('failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
    }

    return Future.value(true);
  });
}

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
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager().registerPeriodicTask(simpleTaskKey, simpleTaskKey);
  }

  Widget? buildBody() {
    switch (currentIndex) {
      case 0:
        return Home();
      case 1:
        return History();
    }
  }

  Duration duration(int hour, int minute) {
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    final delay = scheduledTime.difference(now);
    Future.delayed(delay, () {
      Notifications().sendNotification("Ini aku nyoba lagi");
    });

    return delay;
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
          print("Hello");
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
                              var newdata = await user.add({
                                "title": title.text,
                                "description": description.text,
                                "date": DateTime.now().toString(),
                                "time": "${time.hour}:${time.minute}",
                                "status": "Not done yet",
                                "daily": isDaily
                              });
                              Workmanager().registerOneOffTask(newdata.id, newdata.id, initialDelay: duration(time.hour, time.minute));
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
