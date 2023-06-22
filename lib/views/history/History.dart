// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/Component/CircularButton.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/history/riwayatCard.dart';

class History extends StatefulWidget {
  String user;
  History({required this.user});

  @override
  State<History> createState() => HistoryState();
}

class HistoryState extends State<History> {
  int? puff;
  Future<int?> getPuff() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("puff") == null) {
      return 0;
    } else {
      return prefs.getInt("puff");
    }
  }

  Future<void> plusPuff() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      puff = prefs.getInt("puff");
      prefs.setInt("puff", puff! + 1);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPuff();
  }

  double width(BuildContext context) => MediaQuery.of(context).size.width;
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(widget.user + " Puff");
    return Scaffold(
        body: Container(
      color: BG_COLOR,
      child: Stack(
        children: [
          Column(
            children: [
              FutureBuilder<int?>(
                future: getPuff(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      int? puff = snapshot.data;
                      return Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: (puff! <= 20) ? Colors.white : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: 150,
                        height: 100,
                        child: Center(
                          child: Text(
                            "$puff",
                            style: TextStyle(
                              fontSize: 48,
                              fontFamily: PRIMARY_FONT,
                              color:
                                  (puff <= 20) ? PRIMARY_COLOR : Colors.white,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Text("No puff data available.");
                    }
                  } else if (snapshot.hasError) {
                    return Text("There's an error: ${snapshot.error}");
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              StreamBuilder(
                stream: user.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map((e) {
                        var data = e.data() as Map<String, dynamic>;
                        if (data['status'] == "Done") {
                          return riwayatCard(
                              user: user,
                              title: data['title'],
                              description: data['description'],
                              remaining: "${data['hour']}:${data['minute']}",
                              id: e.id);
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
            ],
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: CircularButton(
                icon: Icons.add,
                color: PRIMARY_COLOR,
                onTap: () {
                  plusPuff();
                }),
          ),
        ],
      ),
    ));
  }
}
