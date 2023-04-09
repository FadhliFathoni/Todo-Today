// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/views/History.dart';
import 'package:todo_today/views/Home.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Color PRIMARY_COLOR = Color.fromARGB(255, 255, 142, 61);
Color BG_COLOR = Color.fromARGB(255, 239, 240, 243);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
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
                      height: height(context) * 0.25,
                      width: width(context) * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Text(
                            "Create",
                            style: TextStyle(color: PRIMARY_COLOR),
                          )),
                          Container(
                            margin: EdgeInsets.only(top: 14),
                            height: 30,
                            child: TextField(
                              controller: title,
                              maxLength: 30,
                              cursorColor: PRIMARY_COLOR,
                              decoration: InputDecoration(
                                hintText: "Title",
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PRIMARY_COLOR)),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: TextField(
                              controller: description,
                              maxLength: 50,
                              cursorColor: PRIMARY_COLOR,
                              decoration: InputDecoration(
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
                            onPressed: () {
                              user.add({"title": title.text, "description": description.text, "date": DateTime.now().toString(), "time": "${time.hour}:${time.minute}", "status": "Not done yet"});
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
