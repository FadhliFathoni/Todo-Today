import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class ParagraphText extends StatelessWidget {
  const ParagraphText({
    super.key,
    required this.text,
    required this.color,
  });
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: PRIMARY_FONT,
        color: color,
      ),
    );
  }
}
