// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/buy/buyPage.dart';
import 'package:todo_today/views/homepage/CircularButton.dart';
import 'package:todo_today/views/homepage/todoCard.dart';

class Home extends StatefulWidget {
  String user;
  Home({required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  double width(BuildContext context) => MediaQuery.of(context).size.width;
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  TimeOfDay time = TimeOfDay.now();
  var list = [];

  late AnimationController animationcontroller;
  late Animation degOneTranslationAnimation;
  late Animation rotationAnimation;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
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
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(widget.user);

    return Scaffold(
      body: Container(
          height: height(context),
          color: BG_COLOR,
          child: Stack(
            children: [
              StreamBuilder(
                stream: user.orderBy('daily', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    int firstIndex = 0;
                    List<QueryDocumentSnapshot> listData = [];
                    for (int x = 0; x < snapshot.data!.size; x++) {
                      var dataId = snapshot.data?.docs[x];
                      var data = dataId!.data() as Map<String, dynamic>;
                      if (data['status'] != "Done") {
                        if (data['daily'] == true) {
                          listData.insert(0, dataId);
                        } else if (data['daily'] == false) {
                          listData.add(dataId);
                        }
                      }
                    }
                    for (int x = 0; x < listData.length; x++) {
                      print(listData[x]);
                    }
                    for (int x = 0; x < listData.length; x++) {
                      if (listData[x]['daily'] == false &&
                          listData[x]['status'] != "Done") {
                        firstIndex = x;
                        print(firstIndex);
                        break;
                      }
                    }
                    for (int x = 0; x < listData.length; x++) {
                      print(listData[x]['daily']);
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listData.length,
                            itemBuilder: (context, index) {
                              var data = listData[index];
                              if (data['daily'] == true) {
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
                                              top: -40,
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
                                          top: 100,
                                          child: Container(
                                            width: width(context),
                                            child: Container(
                                                width: width(context),
                                                child: todoCard(
                                                    user: user,
                                                    title: data['title'],
                                                    description:
                                                        data['description'],
                                                    remaining:
                                                        "${data['hour']}:${data['minute']}",
                                                    id: listData[index].id,
                                                    isdaily: data['daily'])),
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
                                          title: data['title'],
                                          description: data['description'],
                                          remaining:
                                              "${data['hour']}:${data['minute']}",
                                          id: listData[index].id,
                                          isdaily: data['daily']));
                                }
                              } else {
                                if (index == firstIndex) {
                                  return Container(
                                    height: 250,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: -40,
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
                                          top: 100,
                                          child: Container(
                                            width: width(context),
                                            child: Container(
                                                width: width(context),
                                                child: todoCard(
                                                    user: user,
                                                    title: data['title'],
                                                    description:
                                                        data['description'],
                                                    remaining:
                                                        "${data['hour']}:${data['minute']}",
                                                    id: listData[index].id,
                                                    isdaily: data['daily'])),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return todoCard(
                                    user: user,
                                    title: data['title'],
                                    description: data['description'],
                                    remaining:
                                        "${data['hour']}:${data['minute']}",
                                    id: listData[index].id,
                                    isdaily: data['daily'],
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("There is an error"),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
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
                      offset:
                          Offset(degOneTranslationAnimation.value * -100, 0),
                      child: Transform(
                        transform:
                            Matrix4.rotationZ(rotationAnimation.value * 5 / 100)
                              ..scale(degOneTranslationAnimation.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: PRIMARY_COLOR,
                          icon: Icons.attach_money,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return buyPage();
                              },
                            ));
                          },
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset:
                          Offset(0, degOneTranslationAnimation.value * -100),
                      child: Transform(
                        transform:
                            Matrix4.rotationZ(rotationAnimation.value * 5 / 100)
                              ..scale(degOneTranslationAnimation.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: PRIMARY_COLOR,
                          icon: Icons.add,
                          onTap: () {
                            dialogTambah(context, user);
                          },
                        ),
                      ),
                    ),
                    Transform(
                      transform:
                          Matrix4.rotationZ(rotationAnimation.value * 7 / 100),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: PRIMARY_COLOR,
                        icon: Icons.menu,
                        onTap: () {
                          if (animationcontroller.isCompleted) {
                            animationcontroller.reverse();
                          } else {
                            animationcontroller.forward();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Future<dynamic> dialogTambah(
      BuildContext context, CollectionReference<Object?> user) {
    TimeOfDay time = TimeOfDay.now();
    double width(BuildContext context) => MediaQuery.of(context).size.width;
    double height(BuildContext context) => MediaQuery.of(context).size.height;
    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();
    int currentIndex = 0;
    bool isDaily = false;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: Container(
                width: width(context) * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Text(
                      "Create",
                      style: TextStyle(
                          fontFamily: PRIMARY_FONT,
                          color: PRIMARY_COLOR,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      height: 55,
                      child: TextField(
                        controller: title,
                        maxLength: 30,
                        cursorColor: PRIMARY_COLOR,
                        style: TextStyle(fontFamily: PRIMARY_FONT),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          hintStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          hintText: "Title",
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: PRIMARY_COLOR)),
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      child: TextField(
                        controller: description,
                        maxLength: 50,
                        cursorColor: PRIMARY_COLOR,
                        style: TextStyle(fontFamily: PRIMARY_FONT),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          hintStyle: TextStyle(fontFamily: PRIMARY_FONT),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          hintText: "Description",
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: PRIMARY_COLOR)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "${time.hour}",
                              style: TextStyle(fontFamily: PRIMARY_FONT),
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          ),
                          Text(":"),
                          Container(
                            child: Text(
                              "${time.minute}",
                              style: TextStyle(fontFamily: PRIMARY_FONT),
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                          )
                        ],
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                            context: context, initialTime: time);
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
                          },
                        ),
                        Text(
                          "Everyday",
                          style: TextStyle(fontFamily: PRIMARY_FONT),
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
                        await user.add({
                          "title": title.text,
                          "description": description.text,
                          "date": DateTime.now().toString(),
                          "hour": "${time.hour}",
                          "minute": "${time.minute}",
                          "status": "Not done yet",
                          "daily": isDaily
                        });
                        Navigator.pop(context);
                        FlutterBackgroundService().invoke("setAsBackground");
                      },
                      child: Text(
                        "Create",
                        style: TextStyle(fontFamily: PRIMARY_FONT),
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
