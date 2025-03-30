import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainFinancial.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  checkUser({required String username}) async {
    var instance = FirebaseFirestore.instance;
    var docRef = instance.collection("anomali").doc(username);

    var docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainFinancial(user: username),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close,
                color: Colors.red,
                size: 82,
              ),
              Text(
                "Akunnya gaada",
                style: myTextStyle(color: PRIMARY_COLOR),
              ),
            ],
          ),
        ),
      );
    }
  }

  checkLogin() async {
    var prefs = await SharedPreferences.getInstance();
    var user = await prefs.getString("user");
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginFinansial(),
        ),
      );
    } else {
      checkUser(username: user);
    }
  }

  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 2),
      () {
        checkLogin();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: height(context),
        width: width(context),
        child: Center(
          child: Image.asset("assets/icons/Icon.png"),
        ),
      ),
    );
  }
}
