// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';

class riwayatCard extends StatelessWidget {
  CollectionReference user;
  String title, description, remaining;
  int id;
  riwayatCard(
      {required this.user,
      required this.title,
      required this.description,
      required this.remaining,
      required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      ),
                      Text(
                        description,
                        style: TextStyle(
                            fontFamily: PRIMARY_FONT, color: Colors.grey),
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
