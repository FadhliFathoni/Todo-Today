// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/Heading3.dart';
import 'package:todo_today/Component/Text/MoneyText.dart';
import 'package:todo_today/Component/Text/ParagraphText.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/buy/BuyCard.dart';
import 'package:todo_today/views/Money/buy/Dialog.dart';

class BuyPage extends StatefulWidget {
  String user;
  BuyPage({Key? key, required this.user}) : super(key: key);

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  double width(BuildContext context) => MediaQuery.of(context).size.width;

  TextEditingController title = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController link = TextEditingController();

  PlatformFile? pickedFile;
  String fileName = "File Name";

  UploadTask? uploadTask;

  bool isOnline = false;
  bool isMonthly = false;
  @override
  Widget build(BuildContext context) {
    String name = widget.user;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference user = firestore.collection(name + " Spend");

    return Scaffold(
      appBar: AppBar(
        title: Heading1(
          text: "Something To Spend",
          color: PRIMARY_COLOR,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: PRIMARY_COLOR,
        ),
      ),
      body: Container(
        color: BG_COLOR,
        height: height(context),
        width: width(context),
        child: Stack(
          children: [
            StreamBuilder(
              stream: user.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var listData = [];
                  var firstIndex = 0;
                  num total = 0;
                  for (int x = 0; x < snapshot.data!.size; x++) {
                    var dataId =
                        snapshot.data?.docs[x].data() as Map<String, dynamic>;
                    if (dataId['monthly'] == true) {
                      listData.insert(0, dataId);
                      total += dataId['price'];
                    } else {
                      listData.add(dataId);
                    }
                  }
                  for (int x = 0; x < snapshot.data!.size; x++) {
                    if (listData[x]['monthly'] == false) {
                      firstIndex = x;
                      break;
                    }
                  }
                  return ListView.builder(
                    itemCount: listData.length,
                    itemBuilder: (context, x) {
                      if (listData[x]['monthly'] == true) {
                        if (x == 0) {
                          return Column(
                            children: [
                              Container(
                                width: 150,
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Heading1(
                                      text: "Monthly",
                                      color: PRIMARY_COLOR,
                                    ),
                                    ParagraphText(
                                      text: MoneyText(total),
                                      color: PRIMARY_COLOR,
                                    )
                                  ],
                                ),
                              ),
                              BuyCard(listData: listData, index: x)
                            ],
                          );
                        } else {
                          return BuyCard(listData: listData, index: x);
                        }
                      } else {
                        if (x == firstIndex) {
                          return Column(
                            children: [
                              Container(
                                width: 150,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Heading1(
                                  text: "Not Monthly",
                                  color: PRIMARY_COLOR,
                                ),
                              ),
                              BuyCard(listData: listData, index: x)
                            ],
                          );
                        } else {
                          return BuyCard(listData: listData, index: x);
                        }
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("There's an error"),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            dialog().dialogAdd(context, name, pickedFile, fileName, user,
                uploadTask, title, price, isOnline, link, isMonthly),
          ],
        ),
      ),
    );
  }
}
