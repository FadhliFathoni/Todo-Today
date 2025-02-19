// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/API/todoAPI.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';
import 'package:todo_today/views/Todo/homepage/Home.dart';
import 'package:todo_today/views/history/riwayatCard.dart';

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
      child: FutureBuilder(
        future: TodoAPI().getTodo(isHistory: true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.map((e) {
                var data = e;
                if (data.done == 1) {
                  return riwayatCard(
                      user: user,
                      title: data.title!,
                      description: data.description!,
                      remaining: formatDate(data.date!),
                      id: data.id!);
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
              child: MyCircularProgressIndicator(),
            );
          }
        },
      ),
    ));
  }
}
