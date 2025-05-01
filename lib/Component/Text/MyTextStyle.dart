import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

TextStyle MyTextStyle(
        {double? fontSize, FontWeight? fontWeight, Color? color}) =>
    TextStyle(
      color: color ?? PRIMARY_COLOR,
      fontWeight: fontWeight ?? FontWeight.normal,
      fontSize: fontSize ?? 12,
      fontFamily: PRIMARY_FONT,
    );
