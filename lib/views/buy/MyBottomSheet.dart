import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:todo_today/Component/FirebasePicture.dart';
import 'package:todo_today/Component/Text/Heading1.dart';
import 'package:todo_today/Component/Text/ParagraphText.dart';
import 'package:todo_today/main.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBottomSheet {
  Future<dynamic> SpendBottomSheet(
      BuildContext context,
      double height(BuildContext context),
      double width(BuildContext context),
      List<dynamic> listData,
      int x,
      String MoneyText(dynamic value)) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ExpandableBottomSheet(
            background: Container(
              color: Colors.transparent,
            ),
            persistentContentHeight: height(context) / 2,
            persistentHeader: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                height: 20,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 10,
                    width: 40,
                  ),
                )),
            expandableContent: Container(
              height: height(context) / 1.5,
              width: width(context),
              color: Colors.white,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: height(context),
                              width: width(context),
                              child: FirebasePicture(
                                listData: listData,
                                index: x,
                                boxFit: BoxFit.fitWidth,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: width(context),
                      height: 200,
                      child: FirebasePicture(
                        listData: listData,
                        index: x,
                        boxFit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Heading1(text: listData[x]['title'], color: PRIMARY_COLOR),
                  ParagraphText(
                    text: MoneyText(listData[x]['price']),
                    color: PRIMARY_COLOR.withOpacity(0.7),
                  ),
                  (listData[x]['online'])
                      ? GestureDetector(
                          onTap: () async {
                            if (await canLaunchUrl(
                                Uri.parse(listData[x]['link']))) {
                              launchUrl(Uri.parse(listData[x]['link']),
                                  mode: LaunchMode.externalApplication);
                            }
                            ;
                          },
                          child: Container(
                            height: 30,
                            width: 80,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: PRIMARY_COLOR,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText(
                                    text: "Go to link", color: Colors.white),
                                Icon(Icons.keyboard_arrow_right,
                                    color: Colors.white)
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
