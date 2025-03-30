import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class PrimaryTextField extends StatelessWidget {
  final TextEditingController controller;
  int? maxLength;
  int? maxLine;
  final String hintText;
  TextInputType? textInputType = TextInputType.text;
  final void Function(String) onChanged;
  bool? enabled;
  bool? obscureText;
  Widget? suffixWidget;

  PrimaryTextField({
    super.key,
    required this.controller,
    this.maxLength,
    this.maxLine,
    required this.hintText,
    required this.onChanged,
    this.textInputType,
    this.enabled,
    this.obscureText,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 55,
      child: TextSelectionTheme(
        data: TextSelectionThemeData(
            selectionColor: BG_COLOR, selectionHandleColor: PRIMARY_COLOR),
        child: TextField(
          obscureText: obscureText ?? false,
          enabled: enabled ?? true,
          keyboardType: textInputType,
          onChanged: onChanged,
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLine,
          cursorColor: PRIMARY_COLOR,
          style: TextStyle(fontFamily: PRIMARY_FONT),
          decoration: InputDecoration(
            suffix: suffixWidget,
            counterStyle: TextStyle(fontFamily: PRIMARY_FONT),
            hintStyle: TextStyle(fontFamily: PRIMARY_FONT),
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            hintText: hintText,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PRIMARY_COLOR)),
          ),
        ),
      ),
    );
  }
}
