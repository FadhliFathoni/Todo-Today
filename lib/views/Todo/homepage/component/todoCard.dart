// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/API/todoAPI.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/bloc/todo_bloc/todo_bloc.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/model/TodoModel.dart';
import 'package:todo_today/views/Todo/homepage/Home.dart';

class todoCard extends StatefulWidget {
  CollectionReference user;
  String title, description, remaining;
  int id;
  bool isdaily;
  bool? fromUpdate;

  todoCard({
    required this.user,
    required this.title,
    required this.description,
    required this.remaining,
    required this.id,
    required this.isdaily,
    this.fromUpdate,
  });

  @override
  State<todoCard> createState() => _todoCardState();
}

class _todoCardState extends State<todoCard> {
  @override
  Widget build(BuildContext context1) {
    var titleController = TextEditingController();
    titleController.text = widget.title;
    var descriptionController = TextEditingController();
    descriptionController.text = widget.description;
    var isDaily = widget.isdaily;
    TimeOfDay time = convertToTimeOfDay(widget.remaining);
    double height(BuildContext context) => MediaQuery.of(context).size.height;
    double width(BuildContext context) => MediaQuery.of(context).size.width;

    return Container(
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
                          widget.title,
                          style: TextStyle(
                              fontFamily: PRIMARY_FONT,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          formatDate(widget.remaining),
                          style:
                              TextStyle(fontFamily: PRIMARY_FONT, fontSize: 16),
                        )
                      ],
                    ),
                    Text(
                      widget.description,
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
                        final todoBloc = context.read<TodoTodayBloc>();
                        showDialog(
                          context: context1,
                          builder: (context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
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
                                              color: PRIMARY_COLOR,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        PrimaryTextField(
                                          controller: titleController,
                                          hintText: "Title",
                                          onChanged: (value) {},
                                        ),
                                        PrimaryTextField(
                                          controller: descriptionController,
                                          hintText: "Description",
                                          onChanged: (value) {},
                                        ),
                                        GestureDetector(
                                          child: Row(
                                            children: [
                                              Container(
                                                child: Text(
                                                  "${time.hour}",
                                                  style: TextStyle(
                                                      fontFamily: PRIMARY_FONT),
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                              Text(":"),
                                              Container(
                                                child: Text(
                                                  "${time.minute}",
                                                  style: TextStyle(
                                                      fontFamily: PRIMARY_FONT),
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () async {
                                            final TimeOfDay? picked =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: time,
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    colorScheme:
                                                        ColorScheme.light(
                                                      primary: PRIMARY_COLOR,
                                                      onPrimary: Colors.white,
                                                      onSurface: Colors.black,
                                                    ),
                                                    dialogBackgroundColor:
                                                        Colors.white,
                                                    textButtonTheme:
                                                        TextButtonThemeData(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            PRIMARY_COLOR,
                                                      ),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
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
                                              checkColor: Colors.white,
                                              activeColor: PRIMARY_COLOR,
                                              value: isDaily,
                                              onChanged: (value) {
                                                setState(() {
                                                  isDaily = !isDaily;
                                                });
                                              },
                                            ),
                                            Text(
                                              "Everyday",
                                              style: TextStyle(
                                                  fontFamily: PRIMARY_FONT),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    Container(
                                      height: 28,
                                      width: 81,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (!mounted) return;
                                          var prefs = await SharedPreferences
                                              .getInstance();
                                          var username =
                                              await prefs.getString("user");
                                          TodoAPI().delete(widget.id);
                                          await todoBloc.initializeTodo();
                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  MainPage(user: username!),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontFamily: PRIMARY_FONT,
                                            color: Colors.red,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (!mounted) return;
                                          if (titleController.text.isEmpty ||
                                              descriptionController
                                                  .text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Title and Description cannot be empty"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          var prefs = await SharedPreferences
                                              .getInstance();
                                          var username =
                                              await prefs.getString("user");
                                          TodoModel todo = TodoModel(
                                            title: titleController.text,
                                            description:
                                                descriptionController.text,
                                            everyday: (isDaily) ? 1 : 0,
                                            date: formatDateTime(time),
                                            done: 0,
                                            username: username,
                                            id: widget.id,
                                          );
                                          TodoAPI()
                                              .updateTodo(context, todo: todo);
                                          await todoBloc.initializeTodo();
                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  MainPage(user: username!),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Update",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: PRIMARY_FONT,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: PRIMARY_COLOR,
                                        ),
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
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          fontFamily: PRIMARY_FONT,
                          color: PRIMARY_COLOR,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 81,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () async {
                        var prefs = await SharedPreferences.getInstance();
                        var username = prefs.getString("user");

                        if (username == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("User data is missing")),
                          );
                          return;
                        }

                        // Gunakan await agar menunggu selesai sebelum lanjut ke langkah berikutnya
                        await TodoAPI().doneTodo(widget.id);
                        context.read<TodoTodayBloc>().initializeTodo();

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      MainPage(user: username),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "DeliciousHandrawn",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TimeOfDay convertToTimeOfDay(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}
