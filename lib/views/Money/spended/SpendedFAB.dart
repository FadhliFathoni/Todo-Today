import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/Component/CircularButton.dart';
import 'package:todo_today/Component/OkButton.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/main.dart';

class SpendedFAB extends StatelessWidget {
  const SpendedFAB({
    super.key,
    required this.title,
    required this.price,
    required this.user,
    required this.date,
  });

  final TextEditingController title;
  final TextEditingController price;
  final CollectionReference<Object?> user;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 30,
      child: CircularButton(
        icon: Icons.add,
        color: PRIMARY_COLOR,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Center(
                  child: Heading1(
                    text: "Add",
                    color: PRIMARY_COLOR,
                  ),
                ),
                content: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryTextField(
                        controller: title,
                        maxLength: 50,
                        hintText: "Untuk apa",
                        onChanged: (value) {},
                      ),
                      PrimaryTextField(
                        controller: price,
                        maxLength: 50,
                        hintText: "Rp ...",
                        textInputType: TextInputType.number,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
                actions: [
                  OkButton(
                      onPressed: () {
                        user.add({
                          "title": title.text,
                          "price": int.parse(price.text),
                          "date": date
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("Data sucessfully added"),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      text: "Add"),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
