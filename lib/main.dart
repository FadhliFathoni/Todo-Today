// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

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
        onPressed: () {},
        child: Image.asset("assets/icons/plus.png"),
      ),
    );
  }
}
