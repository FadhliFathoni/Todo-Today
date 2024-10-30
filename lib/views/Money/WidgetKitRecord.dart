// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:todo_today/Component/FormattedDateTime.dart';
// import 'package:todo_today/Component/PrimaryTextField.dart';
// import 'package:todo_today/main.dart';
// import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';

// class WidgetKitRecord extends StatefulWidget {
//   const WidgetKitRecord({super.key});

//   @override
//   State<WidgetKitRecord> createState() => _WidgetKitRecordState();
// }

// class _WidgetKitRecordState extends State<WidgetKitRecord> {
//   @override
//   Widget build(BuildContext context) {
//         var instance = FirebaseFirestore.instance;
//     var collection = instance.collection("finance").doc(widget.user);
//     var record = collection.collection("record");
//     var wallet = collection.collection("wallet");
//     var kategori = collection.collection("kategori");
//     return AlertDialog(
//                 backgroundColor: Colors.white,
//                 title: Container(
//                   height: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Stack(
//                     children: [
//                       AnimatedAlign(
//                         duration: Duration(milliseconds: 300),
//                         alignment: selectedType == "pengeluaran"
//                             ? Alignment.centerLeft
//                             : Alignment.centerRight,
//                         child: Container(
//                           width: MediaQuery.of(context).size.width / 3,
//                           decoration: BoxDecoration(
//                             color: selectedType == "pengeluaran"
//                                 ? BG_COLOR
//                                 : BG_COLOR,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 dialogSetState(() {
//                                   selectedType = "pengeluaran";
//                                 });
//                               },
//                               child: Center(
//                                 child: Text(
//                                   "Pengeluaran",
//                                   style: myTextStyle(
//                                     size: 14,
//                                     color: selectedType == "pengeluaran"
//                                         ? Colors.white
//                                         : BG_COLOR,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 dialogSetState(() {
//                                   selectedType = "pemasukan";
//                                 });
//                               },
//                               child: Center(
//                                 child: Text(
//                                   "Pemasukan",
//                                   style: myTextStyle(
//                                     size: 14,
//                                     color: selectedType == "pemasukan"
//                                         ? Colors.white
//                                         : BG_COLOR,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 content: AnimatedSize(
//                   duration: Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Visibility(
//                         visible: selectedType == "pengeluaran",
//                         replacement: Column(
//                           children: [
//                             PrimaryTextField(
//                               controller: totalController,
//                               hintText: "Berapa?",
//                               textInputType: TextInputType.number,
//                               onChanged: (var data) {
//                                 int amount = int.tryParse(data.replaceAll(
//                                         RegExp(r'[^0-9]'), '')) ??
//                                     0;
//                                 totalController.value = TextEditingValue(
//                                   text: formatToRupiah(amount),
//                                   selection: TextSelection.fromPosition(
//                                     TextPosition(
//                                       offset: formatToRupiah(amount).length,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             PrimaryTextField(
//                               controller: titleController,
//                               hintText: "Buat apa?",
//                               onChanged: (var data) {},
//                             ),
//                             PrimaryTextField(
//                               controller: totalController,
//                               hintText: "Berapa?",
//                               textInputType: TextInputType.number,
//                               onChanged: (var data) {
//                                 int amount = int.tryParse(data.replaceAll(
//                                         RegExp(r'[^0-9]'), '')) ??
//                                     0;
//                                 totalController.value = TextEditingValue(
//                                   text: formatToRupiah(amount),
//                                   selection: TextSelection.fromPosition(
//                                     TextPosition(
//                                       offset: formatToRupiah(amount).length,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                             // Visibility(
//                             //   visible: (selectedKategori == "Belanja Online"),
//                             //   child: PrimaryTextField(
//                             //     controller: linkController,
//                             //     hintText: "Ada linknya ngga? (Opsional)",
//                             //     onChanged: (data) {},
//                             //   ),
//                             // ),
//                             StreamBuilder(
//                               stream: kategori.snapshots(),
//                               builder: (context, snapshot) {
//                                 if (!snapshot.hasData) {
//                                   return Container();
//                                 }
//                                 var items = [
//                                   DropdownMenuItem<String>(
//                                     value: "tambah_kategori",
//                                     child: Text(
//                                       "Tambah Kategori",
//                                       style: myTextStyle(color: PRIMARY_COLOR),
//                                     ),
//                                   ),
//                                   ...snapshot.data!.docs
//                                       .map<DropdownMenuItem<String>>((doc) {
//                                     return DropdownMenuItem<String>(
//                                       value: doc['name'],
//                                       child: Text(
//                                         doc['name'],
//                                         style: myTextStyle(),
//                                       ),
//                                     );
//                                   }).toList()
//                                 ];
//                                 return DropdownButton<String>(
//                                   dropdownColor: Colors.white,
//                                   style: myTextStyle(),
//                                   iconEnabledColor: PRIMARY_COLOR,
//                                   items: items,
//                                   value: selectedKategori,
//                                   onChanged: (value) {
//                                     dialogSetState(() {
//                                       selectedKategori = value;
//                                     });
//                                     if (selectedKategori == "tambah_kategori") {
//                                       showDialog(
//                                         context: context,
//                                         builder: (context) => AlertDialog(
//                                           backgroundColor: Colors.white,
//                                           title: Center(
//                                             child: Text(
//                                               "Nambahin Kategori",
//                                               style: myTextStyle(
//                                                 color: PRIMARY_COLOR,
//                                                 size: 18,
//                                               ),
//                                             ),
//                                           ),
//                                           content: PrimaryTextField(
//                                             controller: kategoriController,
//                                             hintText: "Kategori apah",
//                                             onChanged: (data) {},
//                                           ),
//                                           actions: [
//                                             ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor: Colors.white,
//                                               ),
//                                               onPressed: () {
//                                                 kategori.add({
//                                                   "name": kategoriController
//                                                       .value.text,
//                                                   "time": DateTime.now(),
//                                                 });
//                                                 dialogSetState(() {});
//                                                 Navigator.pop(context);
//                                               },
//                                               child: Text(
//                                                 "Syudah",
//                                                 style: myTextStyle(
//                                                   color: PRIMARY_COLOR,
//                                                 ),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   hint: Text(
//                                     "Pilih Kategori",
//                                     style: myTextStyle(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       StreamBuilder(
//                         stream: wallet.snapshots(),
//                         builder: (context, snapshot) {
//                           if (!snapshot.hasData) {
//                             return Container();
//                           }

//                           var walletItems = snapshot.data!.docs
//                               .map<DropdownMenuItem<String>>((doc) {
//                             return DropdownMenuItem<String>(
//                               value: doc.id,
//                               child: Text(
//                                 doc['name'],
//                                 style: myTextStyle(),
//                               ),
//                             );
//                           }).toList();
//                           return DropdownButton<String>(
//                             dropdownColor: Colors.white,
//                             iconEnabledColor: PRIMARY_COLOR,
//                             style: myTextStyle(),
//                             items: walletItems,
//                             value: selectedWallet,
//                             onChanged: (value) {
//                               dialogSetState(() {
//                                 selectedWallet = value;
//                               });
//                             },
//                             hint: Text(
//                               "Pilih Wallet",
//                               style: myTextStyle(),
//                             ),
//                           );
//                         },
//                       ),
//                       GestureDetector(
//                           onTap: () async {
//                             selectDateTime(
//                               context,
//                               dialogSetState: dialogSetState,
//                             );
//                           },
//                           child: Text(
//                             formatDateWithTime(selectedDateTime),
//                             style: myTextStyle(),
//                           )),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: StreamBuilder(
//                             stream: wallet.snapshots(),
//                             builder: (context, snapshot) {
//                               if (!snapshot.hasData) {
//                                 return Container();
//                               }
//                               return ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: PRIMARY_COLOR,
//                                 ),
//                                 onPressed: () {
//                                   int totalAmount = 0;
//                                   if (titleController.value.text.isNotEmpty &&
//                                       selectedKategori != null &&
//                                       totalController.value.text.isNotEmpty &&
//                                       selectedWallet != null) {
//                                     totalAmount = convertRupiahToInt(
//                                         totalController.value.text);
//                                     if (selectedType == "pengeluaran") {
//                                       record.add({
//                                         "title": titleController.value.text,
//                                         "kategori": selectedKategori,
//                                         "time": selectedDateTime,
//                                         "total": totalAmount,
//                                         "type": "Pengeluaran",
//                                         "wallet": selectedWallet,
//                                         // "link": (selectedKategori ==
//                                         //         "Belanja Online")
//                                         //     ? linkController.value.text
//                                         //     : "",
//                                       });
//                                     }
//                                   } else if (selectedType == "pemasukan" &&
//                                       totalController.value.text.isNotEmpty) {
//                                     totalAmount = convertRupiahToInt(
//                                         totalController.value.text);
//                                     record.add({
//                                       "time": selectedDateTime,
//                                       "total": totalAmount,
//                                       "type": "Pemasukan",
//                                       "wallet": selectedWallet,
//                                     });
//                                   }
//                                   if (totalAmount != 0) {
//                                     updateAmount(
//                                       selectedWallet:
//                                           selectedWallet!.toLowerCase(),
//                                       selectedType: selectedType.toLowerCase(),
//                                       totalAmount: totalAmount,
//                                       snapshot: snapshot,
//                                       wallet: wallet,
//                                     );
//                                   }
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text(
//                                   "Syudah",
//                                   style: myTextStyle(color: PRIMARY_COLOR),
//                                 ),
//                               );
//                             }),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//   }
// }