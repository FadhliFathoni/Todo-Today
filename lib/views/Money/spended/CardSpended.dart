import 'package:flutter/material.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/Heading3.dart';
import 'package:todo_today/Component/Text/MoneyText.dart';
import 'package:todo_today/main.dart';

class CardSpended extends StatelessWidget {
  const CardSpended({
    super.key,
    required this.title,
    required this.price,
  });

  final String title;
  final num price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      height: 100,
      margin: EdgeInsets.only(top: 10, right: 20, left: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Heading1(
            text: title,
            color: PRIMARY_COLOR,
          ),
          Heading3(
            text: "-" +
                MoneyText(
                  price,
                ),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
