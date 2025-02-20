// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_today/bloc/history_bloc/history_bloc.dart';
import 'package:todo_today/bloc/history_bloc/history_state.dart';
import 'package:todo_today/bloc/todo_bloc/todo_state.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
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
      height: height(context),
      width: width(context),
      color: BG_COLOR,
      child: BlocBuilder<HistoryTodoBloc, HistoryStates>(
        builder: (context, snapshot) {
          if (snapshot is HistoryLoading) {
            return Center(
              child: MyCircularProgressIndicator(),
            );
          } else if (snapshot is HistoryLoaded) {
            return RefreshIndicator(
              backgroundColor: Colors.white,
              color: PRIMARY_COLOR,
              onRefresh: () async {
                context.read<HistoryTodoBloc>().initializeTodo();
              },
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.todos.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var data = snapshot.todos[index];
                        if (data.done == 1) {
                          return riwayatCard(
                            user: user,
                            title: data.title!,
                            description: data.description!,
                            remaining: formatDate(data.date!),
                            id: data.id!,
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot is HistoryError) {
            return Center(
              child: Text(
                "Error " + snapshot.error,
                style: myTextStyle(),
              ),
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
