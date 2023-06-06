// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:todo_today/main.dart';

class todoCard extends StatelessWidget {
  CollectionReference user;
  String title, description, remaining, id;
  bool isdaily;
  todoCard(
      {required this.user,
      required this.title,
      required this.description,
      required this.remaining,
      required this.id,
      required this.isdaily});

  @override
  Widget build(BuildContext context) {
    var titleController = TextEditingController();
    var descriptionController = TextEditingController();
    var isDaily = isdaily;
    TimeOfDay time = TimeOfDay.now();
    double height(BuildContext context) => MediaQuery.of(context).size.height;
    double width(BuildContext context) => MediaQuery.of(context).size.width;
    return Container(
      // width: 100,
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: 11, horizontal: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 24, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                                fontFamily: PRIMARY_FONT,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            remaining,
                            style: TextStyle(
                                fontFamily: PRIMARY_FONT, fontSize: 16),
                          )
                        ],
                      ),
                      Text(
                        description,
                        style: TextStyle(
                            fontFamily: PRIMARY_FONT, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        width: 81,
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      content: Container(
                                        height: height(context) * 0.28,
                                        width: width(context) * 0.7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                                child: Text(
                                              "Update",
                                              style: TextStyle(
                                                  fontFamily: PRIMARY_FONT,
                                                  color: PRIMARY_COLOR),
                                            )),
                                            Container(
                                              margin: EdgeInsets.only(top: 14),
                                              height: 30,
                                              child: TextField(
                                                controller: titleController,
                                                maxLength: 30,
                                                cursorColor: PRIMARY_COLOR,
                                                style: TextStyle(
                                                    fontFamily: PRIMARY_FONT),
                                                decoration: InputDecoration(
                                                  counterStyle: TextStyle(
                                                      fontFamily: PRIMARY_FONT),
                                                  hintStyle: TextStyle(
                                                      fontFamily: PRIMARY_FONT),
                                                  hintText: "Title",
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey)),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  PRIMARY_COLOR)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: TextField(
                                                controller:
                                                    descriptionController,
                                                maxLength: 50,
                                                cursorColor: PRIMARY_COLOR,
                                                style: TextStyle(
                                                    fontFamily: PRIMARY_FONT),
                                                decoration: InputDecoration(
                                                  counterStyle: TextStyle(
                                                      fontFamily: PRIMARY_FONT),
                                                  hintStyle: TextStyle(
                                                      fontFamily: PRIMARY_FONT),
                                                  hintText: "Description",
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey)),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  PRIMARY_COLOR)),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "${time.hour}",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              PRIMARY_FONT),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey))),
                                                  ),
                                                  Text(":"),
                                                  Container(
                                                    child: Text(
                                                      "${time.minute}",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              PRIMARY_FONT),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .grey))),
                                                  )
                                                ],
                                              ),
                                              onTap: () async {
                                                final TimeOfDay? picked =
                                                    await showTimePicker(
                                                        context: context,
                                                        initialTime: time);
                                                if (picked != null) {
                                                  setState(() {
                                                    time = picked;
                                                  });
                                                }
                                              },
                                            ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                    value: isDaily,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        isDaily = !isDaily;
                                                      });
                                                    }),
                                                Text(
                                                  "Everyday",
                                                  style: TextStyle(
                                                      fontFamily: PRIMARY_FONT),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Container(
                                            height: 28,
                                            width: 81,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                user.doc(id).delete();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Delete",
                                                style: TextStyle(
                                                    fontFamily: PRIMARY_FONT,
                                                    color: Colors.red),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white),
                                            )),
                                        Container(
                                          margin: EdgeInsets.only(right: 14),
                                          height: 28,
                                          width: 81,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              user.doc(id).update({
                                                "title": (titleController
                                                        .text.isNotEmpty)
                                                    ? titleController.text
                                                    : title,
                                                "description":
                                                    (descriptionController
                                                            .text.isNotEmpty)
                                                        ? descriptionController
                                                            .text
                                                        : description,
                                                // "hour": "${time.hour}",
                                                // "minute": "${time.minute}",
                                                "daily": isDaily
                                              });
                                              FlutterBackgroundService()
                                                  .invoke("setAsBackground");
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Update",
                                              style: TextStyle(
                                                  fontFamily: PRIMARY_FONT),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: PRIMARY_COLOR),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, elevation: 0),
                          child: Text(
                            "Edit",
                            style: TextStyle(
                                fontFamily: PRIMARY_FONT, color: PRIMARY_COLOR),
                          ),
                        )),
                    Container(
                      width: 81,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          user.doc(id).update({"status": "Done"});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_COLOR),
                        child: Text(
                          "Done",
                          style: TextStyle(fontFamily: "DeliciousHandrawn"),
                        ),
                      ),
                    ),
                  ],
                )
              ]),
        ),
      ),
    );
  }
}
