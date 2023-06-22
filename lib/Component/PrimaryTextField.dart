import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class PrimaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final String hintText;
  TextInputType? textInputType = TextInputType.text;
  final void Function(String) onChanged;

  PrimaryTextField(
      {super.key,
      required this.controller,
      required this.maxLength,
      required this.hintText,
      required this.onChanged,
      this.textInputType});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      child: TextField(
        keyboardType: textInputType,
        onChanged: onChanged,
        controller: controller,
        maxLength: maxLength,
        cursorColor: PRIMARY_COLOR,
        style: TextStyle(fontFamily: PRIMARY_FONT),
        decoration: InputDecoration(
          counterStyle: TextStyle(fontFamily: PRIMARY_FONT),
          hintStyle: TextStyle(fontFamily: PRIMARY_FONT),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          hintText: hintText,
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: PRIMARY_COLOR)),
        ),
      ),
    );
  }
}
