import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_today/Component/FormattedDateTime.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';
import 'package:url_launcher/url_launcher.dart';

TextStyle myTextStyle({double? size, FontWeight? fontWeight, Color? color}) {
  return TextStyle(
    fontSize: size ?? 14,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: color ?? Colors.black.withOpacity(0.8),
    fontFamily: PRIMARY_FONT,
  );
}

dynamic myElevatedButtonStyle(
    {Color? backgroundColor, Color? foregroundColor}) {
  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? Colors.white,
    foregroundColor: foregroundColor ?? PRIMARY_COLOR,
  );
}

String formatDateWithShortMonth(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return DateFormat("d MMM")
      .format(date)
      .toUpperCase(); // Contoh output: "17 Aug"
}

// Fungsi untuk mengambil waktu dari Timestamp (contoh: "17:23")
String formatTimeOnly(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return DateFormat("HH:mm").format(date); // Contoh output: "17:23"
}

class FinancialTile extends StatelessWidget {
  final DocumentSnapshot<Object?> data;

  FinancialTile({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final dataMap = data.data() as Map<String, dynamic>?;
    final isIncome = dataMap?["type"] == "Pemasukan";
    final colorIndicator = isIncome ? Colors.green : Colors.red;
    final title = dataMap?["title"] ?? dataMap?["type"];
    final totalAmount = formatToRupiah(
      dataMap?["total"] * (isIncome ? 1 : -1),
    );
    final category = dataMap!.containsKey("kategori")
        ? dataMap["kategori"]
        : dataMap["wallet"];
    final date = convertTimestampToIndonesianDate(dataMap["time"])!;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: BG_COLOR, shape: BoxShape.circle),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(formatDateWithShortMonth(dataMap["time"]),
                        style: myTextStyle(size: 12, color: PRIMARY_COLOR)),
                    Text(formatTimeOnly(dataMap["time"]),
                        style: myTextStyle(size: 12, color: PRIMARY_COLOR))
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalAmount,
                    style: myTextStyle(),
                  ),
                  Text(
                    title,
                    style: myTextStyle(),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(date, style: myTextStyle()),
              Text(category, style: myTextStyle()),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialTile1 extends StatelessWidget {
  final DocumentSnapshot<Object?> data;
  final CollectionReference<Map<String, dynamic>> record;
  final CollectionReference<Map<String, dynamic>> wallet;

  FinancialTile1(
      {required this.data,
      required this.record,
      required this.wallet,
      super.key});

  @override
  Widget build(BuildContext context) {
    final dataMap = data.data() as Map<String, dynamic>?;
    final isIncome = dataMap?["type"].toString().toLowerCase() == "pemasukan";
    final colorIndicator = isIncome ? Colors.green : Colors.red;
    final title = dataMap?["title"] ?? dataMap?["type"];
    final totalAmount = formatToRupiah(
      dataMap?["total"] * (isIncome ? 1 : -1),
    );
    final category = dataMap!.containsKey("kategori")
        ? dataMap["kategori"]
        : dataMap["wallet"];
    final date = convertTimestampToIndonesianDate(dataMap["time"])!;

    return GestureDetector(
      onLongPress: () {
        var titleController = TextEditingController(text: dataMap["title"]);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                (!isIncome) ? "Edit Record" : "Hapus Record",
                style: myTextStyle(size: 18, color: PRIMARY_COLOR),
              ),
            ),
            content: PrimaryTextField(
                controller: titleController,
                hintText: (!isIncome) ? dataMap["title"] : "",
                onChanged: (data) {}),
            actions: [
              StreamBuilder(
                  stream: wallet.snapshots(),
                  builder: (context, snapshot) {
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () {
                          record.doc(data.id).delete().then(
                            (_) {
                              updateAmount(
                                selectedWallet:
                                    dataMap["wallet"].toString().toLowerCase(),
                                selectedType:
                                    dataMap["type"].toString().toLowerCase(),
                                totalAmount: dataMap["total"],
                                snapshot: snapshot,
                                wallet: wallet,
                                isDelete: true,
                              );
                            },
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Hapus",
                          style: myTextStyle(color: PRIMARY_COLOR),
                        ));
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
                onPressed: () {
                  record.doc(data.id).set({
                    "title": titleController.value.text,
                    "wallet": dataMap["wallet"],
                    "type": dataMap["type"],
                    "total": dataMap["total"],
                    "time": dataMap["time"],
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  "Syudah",
                  style: myTextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(color: BG_COLOR, shape: BoxShape.circle),
                  child: Text(formatTimeOnly(dataMap["time"]),
                      style: myTextStyle(
                        size: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: myTextStyle(
                        size: 18,
                      ),
                    ),
                    if (dataMap["type"] == "Pengeluaran")
                      Text(
                        dataMap["kategori"],
                        style: myTextStyle(),
                      )
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  totalAmount,
                  style: myTextStyle(
                      color: (isIncome) ? Colors.green : Colors.red, size: 16),
                ),
                Text(dataMap["wallet"],
                    style: myTextStyle(fontWeight: FontWeight.normal))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void checkIsExist(String user) async {
  var doc = FirebaseFirestore.instance.collection("finance").doc(user);
  var wallet = doc.collection("wallet");
  var kategori = doc.collection("kategori");

  var tabunganDoc = await wallet.doc("Tabungan").get();
  if (!tabunganDoc.exists) {
    wallet.doc("Tabungan").set({
      "name": "Tabungan",
      "amount": 0,
      "time": DateTime.now(),
    });
  }

  var danaDaruratDoc = await wallet.doc("Dana Darurat").get();
  if (!danaDaruratDoc.exists) {
    wallet.doc("Dana Darurat").set({
      "name": "Dana Darurat",
      "amount": 0,
      "time": DateTime.now(),
    });
  }

  var kebutuhanDoc = await wallet.doc("Kebutuhan").get();
  if (!kebutuhanDoc.exists) {
    wallet.doc("Kebutuhan").set({
      "name": "Kebutuhan",
      "amount": 0,
      "maxAmount": 0,
      "time": DateTime.now(),
    });
  }

  var kategoriDoc = await kategori.get();
  if (kategoriDoc.size == 0) {
    kategori.add({
      "name": "Jajan",
      "time": DateTime.now(),
    });
    kategori.add({
      "name": "Belanja Online",
      "time": DateTime.now(),
    });
  }
}

String formatToRupiah(int amount) {
  final formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatter.format(amount);
}

int convertRupiahToInt(String formattedAmount) {
  String numericString = formattedAmount.replaceAll(RegExp(r'[^0-9]'), '');
  return int.parse(numericString);
}

void updateAmount({
  required String selectedWallet,
  required String selectedType,
  required int totalAmount,
  required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  required CollectionReference<Map<String, dynamic>> wallet,
  bool? isDelete,
}) {
  QueryDocumentSnapshot<Map<String, dynamic>>? walletDoc;

  for (var doc in snapshot.data!.docs) {
    var data = doc.data();
    if (data["name"].toString().toLowerCase() == selectedWallet.toLowerCase() ||
        doc.id.toLowerCase() == selectedWallet.toLowerCase()) {
      walletDoc = doc;
      break;
    }
  }

  print("WALLET ${walletDoc != null}");
  if (walletDoc != null) {
    int currentAmount = walletDoc["amount"] ?? 0;
    int updatedAmount = 0;

    if (isDelete == true) {
      if (selectedType == "pengeluaran") {
        updatedAmount = selectedWallet == "kebutuhan"
            ? currentAmount - totalAmount
            : currentAmount + totalAmount;
        print("MASUK SINI1");
      } else {
        print("MASUK SINI2");
        if (selectedWallet == "kebutuhan") {
          int currentAmount = walletDoc["maxAmount"] ?? 0;
          updatedAmount = currentAmount - totalAmount;
        } else {
          updatedAmount = currentAmount + totalAmount;
        }
      }
    } else {
      if (selectedType == "pengeluaran") {
        print("MASUK SINI3");
        updatedAmount = selectedWallet == "kebutuhan"
            ? currentAmount + totalAmount
            : currentAmount - totalAmount;
      } else {
        print("MASUK SINI4");
        updatedAmount = selectedWallet == "kebutuhan"
            ? (walletDoc["maxAmount"] ?? 0) + totalAmount
            : currentAmount + totalAmount;
      }
    }

    if (selectedWallet == "kebutuhan" && selectedType != "pengeluaran") {
      wallet.doc(walletDoc.id).update({"maxAmount": updatedAmount});
    } else {
      wallet.doc(walletDoc.id).update({"amount": updatedAmount});
    }
  }
}

void resetWallet(
    {required CollectionReference<Map<String, dynamic>> wallet,
    required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    required String selectedWallet}) {
  QueryDocumentSnapshot<Map<String, dynamic>>? walletDoc;
  for (var doc in snapshot.data!.docs) {
    var data = doc.data();
    if (data["name"].toString().toLowerCase() == selectedWallet.toLowerCase() ||
        doc.id.toLowerCase() == selectedWallet.toLowerCase()) {
      walletDoc = doc;
      break;
    }
  }
  if (walletDoc!.data()["name"] == "Kebutuhan") {
    wallet.doc(walletDoc.id).set({
      "name": walletDoc.data()["name"],
      "amount": 0,
      "maxAmount": 0,
      "time": DateTime.now(),
    });
  } else {
    wallet.doc(walletDoc.id).set({
      "name": walletDoc.data()["name"],
      "amount": 0,
      "time": DateTime.now(),
    });
  }
}

Future<void> generateExcel({
  required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  required BuildContext context,
}) async {
  var dataSnapshot = snapshot.data!.docs;
  var excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];

  List<TextCellValue> header = [
    TextCellValue("Tipe"),
    TextCellValue("Wallet"),
    TextCellValue("Title"),
    TextCellValue("Kategori"),
    TextCellValue("Total"),
    TextCellValue("Waktu"),
  ];
  sheet.appendRow(header);

  for (var doc in dataSnapshot) {
    var data = doc.data();
    sheet.appendRow([
      TextCellValue(data["type"]),
      TextCellValue(data["wallet"]),
      TextCellValue(data["title"] ?? ""),
      TextCellValue(data["kategori"] ?? ""),
      TextCellValue(formatToRupiah(data["total"])),
      TextCellValue(formatDateWithTime((data["time"] as Timestamp).toDate())),
    ]);
  }

  Directory? outputDirectory;
  if (Platform.isAndroid && await Permission.manageExternalStorage.isGranted) {
    outputDirectory = await getExternalStorageDirectory();
  } else {
    String? outputPath = await FilePicker.platform.getDirectoryPath();
    if (outputPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Penyimpanan dibatalkan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    outputDirectory = Directory(outputPath);
  }

  DateTime now = DateTime.now();
  String basePath =
      '${outputDirectory!.path}/${now.year}-${now.month}-${now.day}-CatatanFinansial';

  int counter = 0;
  String filePath;
  do {
    counter++;
    filePath = '$basePath${counter == 1 ? "" : "-$counter"}.xlsx';
  } while (await File(filePath).exists());

  List<int> bytes = await excel.encode()!;
  await File(filePath).writeAsBytes(bytes);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      "Excel telah tersimpan di $filePath",
      style: TextStyle(fontSize: 14),
    ),
    backgroundColor: Colors.green,
  ));

  Navigator.pop(context);
}

Future<String?> getDownloadDirectoryPath() async {
  try {
    final directory = await getExternalStorageDirectory();
    final downloadDirectory = Directory('/storage/emulated/0/Download');
    if (await downloadDirectory.exists()) {
      return downloadDirectory.path;
    } else {
      return directory?.path;
    }
  } catch (e) {
    print("Error getting download directory: $e");
    return null;
  }
}

// bool isRequestingPermission =
//     false; // Tambahkan flag untuk memantau status izin

// Future<void> requestStoragePermission() async {
//   if (isRequestingPermission)
//     return; // Cegah permintaan baru jika ada yang berjalan

//   isRequestingPermission = true; // Set flag sebelum memulai request
//   try {
//     var status = await Permission.storage.status;

//     if (!status.isGranted) {
//       status = await Permission.storage.request();

//       if (status.isGranted) {
//         print("Izin penyimpanan diberikan.");
//       } else if (status.isDenied) {
//         print("Izin penyimpanan ditolak.");
//       } else if (status.isPermanentlyDenied) {
//         openAppSettings();
//       }
//     } else {
//       print("Izin penyimpanan sudah diberikan sebelumnya.");
//     }
//   } finally {
//     isRequestingPermission = false; // Reset flag setelah request selesai
//   }
// }
