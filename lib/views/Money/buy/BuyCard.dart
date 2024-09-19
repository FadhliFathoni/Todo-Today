// import 'package:flutter/material.dart';
// import 'package:todo_today/Component/FirebasePicture.dart';
// import 'package:todo_today/Component/OkButton.dart';
// import 'package:todo_today/Component/Text/Heading1.dart';
// import 'package:todo_today/Component/Text/MoneyText.dart';
// import 'package:todo_today/Component/Text/ParagraphText.dart';
// import 'package:todo_today/main.dart';
// import 'package:todo_today/views/Money/buy/MyBottomSheet.dart';

// class BuyCard extends StatelessWidget {
//   const BuyCard({
//     Key? key,
//     required this.listData,
//     required this.index,
//   }) : super(key: key);

//   final List listData;
//   final int index;

//   double height(BuildContext context) => MediaQuery.of(context).size.height;
//   double width(BuildContext context) => MediaQuery.of(context).size.width;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(
//         top: 10,
//         left: 25,
//         right: 25,
//       ),
//       padding: EdgeInsets.symmetric(
//         vertical: 20,
//         horizontal: 20,
//       ),
//       width: width(context) * 8.5 / 10,
//       decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(20)),
//       child: Stack(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: FirebasePicture(
//                     listData: listData,
//                     index: index,
//                     boxFit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   margin: EdgeInsets.only(left: 10),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.max,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Heading1(
//                           text: listData[index]['title'], color: PRIMARY_COLOR),
//                       Container(
//                         margin: EdgeInsets.symmetric(vertical: 5),
//                         child: ParagraphText(
//                           text: MoneyText(listData[index]['price']),
//                           color: PRIMARY_COLOR.withOpacity(0.8),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: OkButton(
//               onPressed: () {
//                 MyBottomSheet().SpendBottomSheet(
//                     context, height, width, listData, index, MoneyText);
//               },
//               text: "Detail",
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
