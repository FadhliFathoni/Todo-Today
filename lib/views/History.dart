// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class History extends StatefulWidget {
  String user;
  History({required this.user});

  @override
  State<History> createState() => HistoryState();
}

class HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(widget.user);
    return Scaffold(
        body: Container(
      color: BG_COLOR,
      child: StreamBuilder(
        stream: user.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((e) {
                var data = e.data() as Map<String, dynamic>;
                if (data['status'] == "Done") {
                  return riwayatCard(user, data['title'], data['description'], "${data['hour']}:${data['minute']}", e.id);
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ));
  }

  Container riwayatCard(CollectionReference user, String title, String description, String remaining, String id) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          height: 120,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 14),
                    child: Row(
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
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
