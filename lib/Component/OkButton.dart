import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class OkButton extends StatelessWidget {
  const OkButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final void Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 14),
      height: 28,
      width: 81,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontFamily: PRIMARY_FONT),
        ),
        style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
      ),
    );
  }
}