// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/API/todoAPI.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/ParagraphText.dart';
import 'package:todo_today/bloc/todo_bloc/todo_bloc.dart';
import 'package:todo_today/bloc/todo_bloc/todo_state.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainFinancial.dart';
import 'package:todo_today/mainWishList.dart';
import 'package:todo_today/Component/CircularButton.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/model/TodoModel.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:todo_today/views/Todo/homepage/component/MyCheckBox.dart';
import 'package:todo_today/views/Todo/homepage/component/todoCard.dart';

class Home extends StatefulWidget {
  String user;
  Home({required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  double width(BuildContext context) => MediaQuery.of(context).size.width;
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  TimeOfDay time = TimeOfDay.now();
  var list = [];

  late AnimationController animationcontroller;
  late Animation degOneTranslationAnimation;
  late Animation rotationAnimation;
  late AnimationController fabController;

  double turns = 0.0;
  bool isClicked = false;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    animationcontroller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation =
        Tween(begin: 0.0, end: 1.0).animate(animationcontroller);
    rotationAnimation = Tween(begin: 180.0, end: 1.0).animate(
        CurvedAnimation(parent: animationcontroller, curve: Curves.easeOut));
    super.initState();
    animationcontroller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationcontroller.dispose();
    fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(widget.user);

    return Scaffold(
      backgroundColor: BG_COLOR,
      body: Container(
        height: height(context),
        width: width(context),
        color: BG_COLOR,
        child: Stack(
          children: [
            BlocBuilder(
              bloc: TodoTodayBloc()..getTodo(),
              builder: (context, snapshot) {
                if (snapshot is TodoLoading) {
                  return Center(
                      child: CircularProgressIndicator(color: PRIMARY_COLOR));
                } else if (snapshot is TodoLoaded) {
                  int firstIndex = 0;
                  List<TodoModel> listData = [];
                  for (int x = 0; x < snapshot.todos.length; x++) {
                    var data = snapshot.todos[x];
                    if (data.done != 1) {
                      if (data.everyday == 1) {
                        listData.insert(0, data);
                      } else if (data.everyday == 0) {
                        listData.add(data);
                      }
                    }
                  }
                  for (int x = 0; x < listData.length; x++) {
                    print(listData[x]);
                  }
                  for (int x = 0; x < listData.length; x++) {
                    if (listData[x].everyday == 0 && listData[x].done != 1) {
                      firstIndex = x;
                      print(firstIndex);
                      break;
                    }
                  }
                  for (int x = 0; x < listData.length; x++) {
                    print(listData[x].everyday);
                  }
                  return RefreshIndicator(
                    backgroundColor: Colors.white,
                    color: PRIMARY_COLOR,
                    onRefresh: () async {
                      await context.read<TodoTodayBloc>().initializeTodo();
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listData.length,
                            itemBuilder: (context, index) {
                              var data = listData[index];
                              if (data.everyday == 1) {
                                if (index == 0) {
                                  return Container(
                                    height: 250,
                                    child: Stack(
                                      children: [
                                        Stack(
                                          children: [
                                            Image.asset(
                                              "assets/images/batu-daily.png",
                                              width: 200,
                                            ),
                                            Positioned(
                                              left: 0,
                                              right: 0,
                                              top: -50,
                                              bottom: 0,
                                              child: Container(
                                                color: Colors.transparent,
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                    child: Text(
                                                  "Daily",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          "DeliciousHandrawn",
                                                      fontSize: 36),
                                                )),
                                              ),
                                            )
                                          ],
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: width(context),
                                            child: todoCard(
                                              user: user,
                                              title: data.title!,
                                              description: data.description!,
                                              remaining: data.date!,
                                              id: data.id!,
                                              isdaily: data.everyday == 1,
                                              setState: setState,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container(
                                    width: width(context),
                                    child: todoCard(
                                      user: user,
                                      title: data.title!,
                                      description: data.description!,
                                      remaining: data.date!,
                                      id: data.id!,
                                      isdaily: data.everyday == 1,
                                      setState: setState,
                                    ),
                                  );
                                }
                              } else {
                                if (index == firstIndex) {
                                  return Container(
                                    height: 250,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: -50,
                                          right: 0,
                                          child: Stack(
                                            children: [
                                              Image.asset(
                                                "assets/images/batu-not-daily.png",
                                                width: 250,
                                              ),
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                top: 10,
                                                bottom: 0,
                                                child: Container(
                                                  color: Colors.transparent,
                                                  height: 100,
                                                  width: 100,
                                                  child: Center(
                                                      child: Text(
                                                    "Not Daily",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily:
                                                            "DeliciousHandrawn",
                                                        fontSize: 36),
                                                  )),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: width(context),
                                            child: todoCard(
                                              user: user,
                                              title: data.title!,
                                              description: data.description!,
                                              remaining: data.date!,
                                              id: data.id!,
                                              isdaily: data.everyday == 1,
                                              setState: setState,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return todoCard(
                                    user: user,
                                    title: data.title!,
                                    description: data.description!,
                                    remaining: data.date!,
                                    id: data.id!,
                                    isdaily: data.everyday == 1,
                                    setState: setState,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot is TodoError) {
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
            Positioned(
              bottom: 30,
              right: 30,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  IgnorePointer(
                    child: Container(
                      color: Colors.transparent,
                      width: 150,
                      height: 150,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(degOneTranslationAnimation.value * -100, 0),
                    child: Transform(
                      transform:
                          Matrix4.rotationZ(rotationAnimation.value * 5 / 100)
                            ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: PRIMARY_COLOR,
                        icon: Icons.favorite_border,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Mainwishlist();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(degOneTranslationAnimation.value * -60,
                        degOneTranslationAnimation.value * -60),
                    child: Transform(
                      transform:
                          Matrix4.rotationZ(rotationAnimation.value * 5 / 100)
                            ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: PRIMARY_COLOR,
                        icon: Icons.attach_money,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MainFinancial(user: widget.user);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, degOneTranslationAnimation.value * -100),
                    child: Transform(
                      transform:
                          Matrix4.rotationZ(rotationAnimation.value * 5 / 100)
                            ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: PRIMARY_COLOR,
                        icon: Icons.add,
                        onTap: () {
                          dialogTambah(context, setState);
                        },
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    alignment: Alignment.center,
                    turns: turns,
                    duration: Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () {
                        if (isClicked) {
                          setState(
                            () {
                              turns -= 1 / 4;
                              animationcontroller.reverse();
                              fabController.reverse();
                            },
                          );
                        } else {
                          turns += 1 / 4;
                          animationcontroller.forward();
                          fabController.forward();
                        }
                        isClicked = !isClicked;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: PRIMARY_COLOR,
                          shape: BoxShape.circle,
                        ),
                        height: 50,
                        width: 50,
                        child: Center(
                          child: AnimatedIcon(
                            icon: AnimatedIcons.menu_close,
                            progress: fabController,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Transform(
                  //   transform:
                  //       Matrix4.rotationZ(rotationAnimation.value * 7 / 100),
                  //   alignment: Alignment.center,
                  //   child: CircularButton(
                  //     color: PRIMARY_COLOR,
                  //     icon: Icons.menu,
                  //     onTap: () {
                  //       if (animationcontroller.isCompleted) {
                  //         animationcontroller.reverse();
                  //       } else {
                  //         animationcontroller.forward();
                  //       }
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> dialogTambah(
      BuildContext context, void Function(void Function())) {
    TimeOfDay time = TimeOfDay.now();
    double width(BuildContext context) => MediaQuery.of(context).size.width;
    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();
    bool isDaily = false;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: Container(
                width: width(context) * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Heading1(
                        color: PRIMARY_COLOR,
                        text: "Create",
                      ),
                    ),
                    PrimaryTextField(
                      controller: title,
                      hintText: "Title",
                      maxLength: 30,
                      onChanged: (value) {},
                    ),
                    PrimaryTextField(
                      controller: description,
                      maxLength: 50,
                      hintText: "Description",
                      onChanged: (value) {},
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Container(
                            child: ParagraphText(
                              text: "${time.hour}",
                              color: Colors.black54,
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          ),
                          Text(":"),
                          Container(
                            child: ParagraphText(
                              text: "${time.minute}",
                              color: Colors.black54,
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          )
                        ],
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: time,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary:
                                      PRIMARY_COLOR, // Warna utama (misal, warna tombol OK)
                                  onPrimary: Colors
                                      .white, // Warna teks di atas primary
                                  onSurface: Colors
                                      .black, // Warna teks di atas background
                                ),
                                dialogBackgroundColor:
                                    Colors.white, // Warna background picker
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        PRIMARY_COLOR, // Warna tombol Cancel
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
                        MyCheckBox(
                          value: isDaily,
                          onChanged: (value) {
                            setState(() {
                              isDaily = !isDaily;
                            });
                          },
                        ),
                        ParagraphText(
                          text: "Everyday",
                          color: (isDaily == false)
                              ? Colors.black54
                              : PRIMARY_COLOR,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                Container(
                    margin: EdgeInsets.only(right: 14),
                    height: 28,
                    width: 81,
                    child: ElevatedButton(
                      onPressed: () async {
                        // await user.add({
                        //   "title": title.text,
                        //   "description": description.text,
                        //   "date": DateTime.now().toString(),
                        //   "hour": "${time.hour}",
                        //   "minute": "${time.minute}",
                        //   "status": "Not done yet",
                        //   "daily": isDaily
                        // });
                        var prefs = await SharedPreferences.getInstance();
                        var username = await prefs.getString("user");
                        var data = TodoModel(
                          title: title.text,
                          description: description.text,
                          date: formatDateTime(time),
                          done: 0,
                          everyday: (isDaily) ? 1 : 0,
                          username: username,
                        );
                        TodoAPI().registerTodo(context, todo: data);
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Create",
                        style: TextStyle(
                            fontFamily: PRIMARY_FONT, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR),
                    )),
              ],
            );
          },
        );
      },
    );
  }
}

String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  return DateFormat('HH:mm').format(dateTime);
}

String formatDateTime(TimeOfDay time) {
  DateTime now = DateTime.now();

  String formattedTime =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
  return formattedTime;
}
