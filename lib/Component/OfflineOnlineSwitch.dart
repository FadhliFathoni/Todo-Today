import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class OfflineOnlineSwitch extends StatelessWidget {
  const OfflineOnlineSwitch({
    super.key,
    required this.isOnline,
    required this.onChanged,
  });

  final bool isOnline;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Offline",
          style: TextStyle(
            fontFamily: PRIMARY_FONT,
            color: (isOnline == false) ? PRIMARY_COLOR : Colors.grey,
          ),
        ),
        MySwitch(isOnline: isOnline, onChanged: onChanged),
        Text(
          "Online",
          style: TextStyle(
            fontFamily: PRIMARY_FONT,
            color: (isOnline == false) ? Colors.grey : PRIMARY_COLOR,
          ),
        )
      ],
    );
  }
}

class MySwitch extends StatelessWidget {
  const MySwitch({
    super.key,
    required this.isOnline,
    required this.onChanged,
  });

  final bool isOnline;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
        activeColor: PRIMARY_COLOR,
        inactiveThumbColor: PRIMARY_COLOR,
        activeTrackColor: Colors.grey.withOpacity(0.3),
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
        value: isOnline,
        onChanged: onChanged);
  }
}
