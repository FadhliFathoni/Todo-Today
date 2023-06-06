// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/core/background.dart';
import 'package:todo_today/views/history/History.dart';
import 'package:todo_today/views/homepage/Home.dart';
import 'package:todo_today/views/loginpage/LoginPage.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Color PRIMARY_COLOR = Color.fromARGB(255, 164, 83, 56);
Color BG_COLOR = Color.fromARGB(255, 193, 200, 192);

String PRIMARY_FONT = "DeliciousHandrawn";

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(widget.user);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            "TODO TODAY",
            style: TextStyle(
                color: Colors.black,
                fontFamily: PRIMARY_FONT,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
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

  Future<dynamic> dialogTambah(
      BuildContext context, CollectionReference<Object?> user) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: Container(
                width: width(context) * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Text(
                      "Create",
                      style: TextStyle(
                          fontFamily: PRIMARY_FONT,
                          color: PRIMARY_COLOR,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      height: 55,
                      child: TextField(
                        controller: title,
                        maxLength: 30,
                        cursorColor: PRIMARY_COLOR,
                        style: TextStyle(fontFamily: PRIMARY_FONT),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          hintStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          hintText: "Title",
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: PRIMARY_COLOR)),
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      child: TextField(
                        controller: description,
                        maxLength: 50,
                        cursorColor: PRIMARY_COLOR,
                        style: TextStyle(fontFamily: PRIMARY_FONT),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          hintStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          hintText: "Description",
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: PRIMARY_COLOR)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "${time.hour}",
                              style: TextStyle(fontFamily: PRIMARY_FONT),
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          ),
                          Text(":"),
                          Container(
                            child: Text(
                              "${time.minute}",
                              style: TextStyle(fontFamily: PRIMARY_FONT),
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          )
                        ],
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                            context: context, initialTime: time);
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
                        Text(
                          "Everyday",
                          style: TextStyle(fontFamily: PRIMARY_FONT),
                        ),
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
                        await user.add({
                          "title": title.text,
                          "description": description.text,
                          "date": DateTime.now().toString(),
                          "hour": "${time.hour}",
                          "minute": "${time.minute}",
                          "status": "Not done yet",
                          "daily": isDaily
                        });
                        Navigator.pop(context);
                        FlutterBackgroundService().invoke("setAsBackground");
                      },
                      child: Text(
                        "Create",
                        style: TextStyle(fontFamily: PRIMARY_FONT),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR),
                    )),
              ],
            );
          },
        );
      },
    );
  }
}


