import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/MoneyText.dart';
import 'package:todo_today/main.dart';

class MyBottomBar extends StatelessWidget {
  const MyBottomBar({
    super.key,
    required this.user,
  });

  final CollectionReference<Object?> user;

  @override
  Widget build(BuildContext context) {
    double width(BuildContext context) => MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 0,
      child: Container(
        color: Colors.white,
        height: 50,
        width: width(context),
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
        child: Row(
          children: [
            Heading1(text: "Total: ", color: PRIMARY_COLOR),
            StreamBuilder(
              stream: user.snapshots(),
              builder: (context, snapshot) {
                int total = 0;
                for (int x = 0; x < snapshot.data!.size; x++) {
                  total += snapshot.data!.docs[x]['price'] as int;
                }
                if (snapshot.hasData) {
                  return Heading1(
                    text: MoneyText(total),
                    color: PRIMARY_COLOR,
                  );
                } else if (snapshot.hasError) {
                  return Text("There's an error");
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
