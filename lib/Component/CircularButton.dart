import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final void Function() onTap;
  final IconData icon;
  final Color color;

  CircularButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(100)),
        child: IconButton(
          enableFeedback: true,
          icon: Icon(icon),
          onPressed: onTap,
          color: Colors.white,
        ),
      ),
    );
  }
}
