import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class buyPage extends StatefulWidget {
  const buyPage({super.key});

  @override
  State<buyPage> createState() => _buyPageState();
}

class _buyPageState extends State<buyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SOMETHING TO BUY",
          style: TextStyle(
              color: Colors.black,
              fontFamily: PRIMARY_FONT,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: Container(),
    );
  }
}
