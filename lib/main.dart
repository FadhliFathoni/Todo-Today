// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, must_be_immutable

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/core/background.dart';
import 'package:todo_today/core/firebase_messaging_service.dart';
import 'package:todo_today/views/history/History.dart';
import 'package:todo_today/views/Todo/homepage/Home.dart';
import 'package:todo_today/views/loginpage/LoginPage.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:flutter_widgetkit/flutter_widgetkit.dart";

Color PRIMARY_COLOR = Color.fromARGB(255, 164, 83, 56);
Color BG_COLOR = Color.fromARGB(255, 193, 200, 192);
String PRIMARY_FONT = "DeliciousHandrawn";
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

double height(BuildContext context) => MediaQuery.of(context).size.height;
double width(BuildContext context) => MediaQuery.of(context).size.width;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initializeService();
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await initializeDateFormatting(
      'id', null); // Initialize for Indonesian locale
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessagingService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        color: Colors.white,
        title: "Todo Today",
        debugShowCheckedModeBanner: false,
        home: LoginPage());
  }
}

class MainPage extends StatefulWidget {
  String user;
  MainPage({required this.user});

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
  bool isDaily = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Widget? buildBody() {
    switch (currentIndex) {
      case 0:
        return Home(
          user: widget.user,
        );
      case 1:
        return History(
          user: widget.user,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: GestureDetector(
          onTap: () async {
            FlutterBackgroundService().invoke("stopService");
            final prefs = await SharedPreferences.getInstance();
            prefs.clear();
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return LoginPage();
              },
            ));
          },
          child: Text(
            "Todo Today",
            style: TextStyle(
                color: PRIMARY_COLOR,
                fontFamily: PRIMARY_FONT,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(fontFamily: PRIMARY_FONT),
          unselectedLabelStyle: TextStyle(fontFamily: PRIMARY_FONT),
          currentIndex: currentIndex,
          onTap: (value) {
            currentIndex = value;
            setState(() {});
          },
          selectedItemColor: PRIMARY_COLOR,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
          ]),
    );
  }
}
