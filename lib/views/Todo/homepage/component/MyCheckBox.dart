import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class MyCheckBox extends StatelessWidget {
  const MyCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: PRIMARY_COLOR,
      value: value,
      onChanged: onChanged,
    );
  }
}
