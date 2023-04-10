// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double width(BuildContext context) => MediaQuery.of(context).size.width;
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  TimeOfDay time = TimeOfDay.now();
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection("user1");
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 7),
          color: BG_COLOR,
          child: StreamBuilder(
            stream: user.orderBy('time').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: snapshot.data!.docs.map((e) {
                    var data = e.data() as Map<String, dynamic>;
                    var title = data['title'];
                    if (data['status'] != "Done") {
                      return todoCard(user, data['title'], data['description'], data['time'], e.id);
                    } else {
                      return Container();
                    }
                  }).toList(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("There is an error"),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }

  Container todoCard(CollectionReference user, String title, String description, String remaining, String id) {
    var titleController = TextEditingController();
    var descriptionController = TextEditingController();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: 11, horizontal: 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        remaining,
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey),
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
                              builder: (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  content: Container(
                                    height: height(context) * 0.25,
                                    width: width(context) * 0.7,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: Text(
                                          "Update",
                                          style: TextStyle(color: PRIMARY_COLOR),
                                        )),
                                        Container(
                                          margin: EdgeInsets.only(top: 14),
                                          height: 30,
                                          child: TextField(
                                            controller: titleController,
                                            maxLength: 30,
                                            cursorColor: PRIMARY_COLOR,
                                            decoration: InputDecoration(
                                              hintText: "Title",
                                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PRIMARY_COLOR)),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 30,
                                          margin: EdgeInsets.symmetric(vertical: 10),
                                          child: TextField(
                                            controller: descriptionController,
                                            maxLength: 50,
                                            cursorColor: PRIMARY_COLOR,
                                            decoration: InputDecoration(
                                              hintText: "Description",
                                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PRIMARY_COLOR)),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Row(
                                            children: [
                                              Container(
                                                child: Text("${time.hour}"),
                                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                                              ),
                                              Text(":"),
                                              Container(
                                                child: Text("${time.minute}"),
                                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                                              )
                                            ],
                                          ),
                                          onTap: () async {
                                            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: time);
                                            if (picked != null) {
                                              setState(() {
                                                time = picked;
                                              });
                                            }
                                          },
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
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(right: 14),
                                        height: 28,
                                        width: 81,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            user.doc(id).update({
                                              "title": (titleController.text.isNotEmpty) ? titleController.text : title,
                                              "description": (descriptionController.text.isNotEmpty) ? descriptionController.text : description,
                                              "time": "${time.hour}:${time.minute}",
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text("Update"),
                                          style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
                                        )),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0),
                      child: Text(
                        "Edit",
                        style: TextStyle(color: PRIMARY_COLOR),
                      ),
                    )),
                Container(
                    width: 81,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {
                        user.doc(id).update({"status": "Done"});
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
                      child: Text("Done"),
                    )),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
