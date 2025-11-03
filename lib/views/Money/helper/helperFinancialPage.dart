import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_today/Component/FormattedDateTime.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/mainWishList.dart';

TextStyle myTextStyle({double? size, FontWeight? fontWeight, Color? color}) {
  return TextStyle(
    fontSize: size ?? 14,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: color ?? PRIMARY_COLOR,
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
    if (dataMap == null) return Container();
    final isIncome = dataMap["type"] == "Pemasukan";
    final title = dataMap["title"] ?? dataMap["type"];
    final totalAmount = formatToRupiah(
      dataMap["total"] * (isIncome ? 1 : -1),
    );
    final category = dataMap.containsKey("kategori")
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
    if (dataMap == null) return Container();

    final isIncome = dataMap["type"].toString().toLowerCase() == "pemasukan";
    final title = dataMap["title"] ?? dataMap["type"];
    final totalAmount = formatToRupiah(
      dataMap["total"] * (isIncome ? 1 : -1),
    );

    return GestureDetector(
      onLongPress: () {
        // Get kategori collection reference
        // Extract user ID from record reference path
        // record path is: finance/{user}/record
        var userDoc = record.parent?.parent;
        var userId = userDoc?.id ?? "";
        var instance = FirebaseFirestore.instance;
        var collection = instance.collection("finance").doc(userId);
        var kategori = collection.collection("kategori");

        // Initialize controllers with existing data
        var titleController = TextEditingController(text: dataMap["title"]);
        var totalController = TextEditingController(
          text: formatToRupiah(dataMap["total"]),
        );
        var kategoriController = TextEditingController();

        // Get current values
        DateTime selectedDateTime = (dataMap["time"] as Timestamp).toDate();
        String? selectedKategori = dataMap["kategori"];
        String? selectedWallet = dataMap["wallet"];
        String recordType = dataMap["type"];

        // Date/Time picker function
        Future<void> selectDateTime(BuildContext context,
            StateSetter dialogSetState, DateTime dateInput) async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: dateInput,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: PRIMARY_COLOR,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(dateInput),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: PRIMARY_COLOR,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: PRIMARY_COLOR,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedTime != null) {
              dialogSetState(() {
                selectedDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              });
            }
          }
        }

        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, dialogSetState) => AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  "Edit Record",
                  style: myTextStyle(size: 18, color: PRIMARY_COLOR),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryTextField(
                      controller: titleController,
                      hintText: "Title",
                      onChanged: (data) {},
                    ),
                    const SizedBox(height: 12),
                    PrimaryTextField(
                      controller: totalController,
                      hintText: "Berapa?",
                      textInputType: TextInputType.number,
                      onChanged: (var data) {
                        int amount = int.tryParse(
                                data.replaceAll(RegExp(r'[^0-9]'), '')) ??
                            0;
                        totalController.value = TextEditingValue(
                          text: formatToRupiah(amount),
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              offset: formatToRupiah(amount).length,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (recordType == "Pengeluaran")
                      StreamBuilder(
                        stream: kategori.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }

                          // Filter out duplicate category names - keep only unique ones
                          Set<String> seenCategories = {};
                          List<DropdownMenuItem<String>> categoryItems = [];

                          // Add categories from Firestore, filtering duplicates
                          for (var doc in snapshot.data!.docs) {
                            String? categoryName =
                                doc['name']?.toString().trim();
                            if (categoryName != null &&
                                categoryName.isNotEmpty &&
                                !seenCategories.contains(categoryName)) {
                              seenCategories.add(categoryName);
                              categoryItems.add(
                                DropdownMenuItem<String>(
                                  value: categoryName,
                                  child: Text(
                                    categoryName,
                                    style: myTextStyle(),
                                  ),
                                ),
                              );
                            }
                          }

                          // Ensure the current selected category is included, even if it doesn't exist in Firestore
                          String? trimmedSelectedKategori =
                              selectedKategori?.trim();
                          if (trimmedSelectedKategori != null &&
                              trimmedSelectedKategori.isNotEmpty &&
                              !seenCategories
                                  .contains(trimmedSelectedKategori)) {
                            // Add the existing category to the list if it's not already there
                            categoryItems.add(
                              DropdownMenuItem<String>(
                                value: trimmedSelectedKategori,
                                child: Text(
                                  trimmedSelectedKategori,
                                  style: myTextStyle(),
                                ),
                              ),
                            );
                          }

                          // Build dropdown items
                          List<DropdownMenuItem<String>> items = [
                            // DropdownMenuItem<String>(
                            //   value: "tambah_kategori",
                            //   child: Text(
                            //     "Tambah Kategori",
                            //     style: myTextStyle(color: PRIMARY_COLOR),
                            //   ),
                            // ),
                            ...categoryItems,
                          ];

                          // Ensure validSelectedKategori exists in items
                          Set<String> itemValues = items
                              .map((item) => item.value)
                              .whereType<String>()
                              .toSet();

                          String? finalValidSelectedKategori =
                              trimmedSelectedKategori;
                          if (finalValidSelectedKategori != null &&
                              !itemValues
                                  .contains(finalValidSelectedKategori)) {
                            finalValidSelectedKategori = null;
                          }

                          return DropdownButton<String>(
                            dropdownColor: Colors.white,
                            style: myTextStyle(),
                            iconEnabledColor: PRIMARY_COLOR,
                            items: items,
                            value: finalValidSelectedKategori,
                            onChanged: (value) {
                              dialogSetState(() {
                                selectedKategori = value;
                              });
                              if (selectedKategori == "tambah_kategori") {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Center(
                                      child: Text(
                                        "Nambahin Kategori",
                                        style: myTextStyle(
                                          color: PRIMARY_COLOR,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    content: PrimaryTextField(
                                      controller: kategoriController,
                                      hintText: "Kategori apah",
                                      onChanged: (data) {},
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          kategori.add({
                                            "name":
                                                kategoriController.value.text,
                                            "time": DateTime.now(),
                                          });
                                          dialogSetState(() {});
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Syudah",
                                          style: myTextStyle(
                                            color: PRIMARY_COLOR,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                            hint: Text(
                              "Pilih Kategori",
                              style: myTextStyle(),
                            ),
                          );
                        },
                      ),
                    if (recordType == "Pengeluaran") const SizedBox(height: 12),
                    StreamBuilder(
                      stream: wallet.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }

                        var walletItems = snapshot.data!.docs
                            .map<DropdownMenuItem<String>>((doc) {
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(
                              doc['name'],
                              style: myTextStyle(),
                            ),
                          );
                        }).toList();
                        return DropdownButton<String>(
                          dropdownColor: Colors.white,
                          iconEnabledColor: PRIMARY_COLOR,
                          style: myTextStyle(),
                          items: walletItems,
                          value: selectedWallet,
                          onChanged: (value) {
                            dialogSetState(() {
                              selectedWallet = value;
                            });
                          },
                          hint: Text(
                            "Pilih Wallet",
                            style: myTextStyle(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        await selectDateTime(
                            context, dialogSetState, selectedDateTime);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: PRIMARY_COLOR),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDateWithTime(selectedDateTime),
                              style: myTextStyle(),
                            ),
                            Icon(Icons.calendar_today, color: PRIMARY_COLOR),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                StreamBuilder(
                  stream: wallet.snapshots(),
                  builder: (context, snapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
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
                      ),
                    );
                  },
                ),
                StreamBuilder(
                  stream: wallet.snapshots(),
                  builder: (context, walletSnapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR),
                      onPressed: () async {
                        if (!walletSnapshot.hasData) return;

                        int newTotalAmount =
                            convertRupiahToInt(totalController.value.text);
                        String oldWallet =
                            dataMap["wallet"].toString().toLowerCase();
                        String newWallet = selectedWallet!.toLowerCase();
                        String type = recordType.toString().toLowerCase();
                        int oldTotalAmount = dataMap["total"];

                        // Calculate the difference in amount
                        int amountDifference = newTotalAmount - oldTotalAmount;

                        // If wallet changed, we need to undo old wallet and apply to new wallet
                        bool walletChanged = oldWallet != newWallet;

                        if (walletChanged) {
                          // First, undo the old wallet's calculation
                          updateAmount(
                            selectedWallet: oldWallet,
                            selectedType: type,
                            totalAmount: oldTotalAmount,
                            snapshot: walletSnapshot,
                            wallet: wallet,
                            isDelete: true,
                          );

                          // Wait a bit to ensure wallet update is processed
                          await Future.delayed(Duration(milliseconds: 100));

                          // Get fresh snapshot after wallet update
                          var freshSnapshot = await wallet.get();
                          var freshWalletSnapshot = AsyncSnapshot<
                              QuerySnapshot<Map<String, dynamic>>>.withData(
                            ConnectionState.done,
                            freshSnapshot,
                          );

                          // Then, apply the new wallet's calculation
                          if (newTotalAmount != 0) {
                            updateAmount(
                              selectedWallet: newWallet,
                              selectedType: type,
                              totalAmount: newTotalAmount,
                              snapshot: freshWalletSnapshot,
                              wallet: wallet,
                            );
                          }
                        } else {
                          // Same wallet - just apply the difference
                          if (amountDifference != 0) {
                            // Apply the difference amount
                            if (amountDifference > 0) {
                              // Increasing amount - add the difference
                              updateAmount(
                                selectedWallet: newWallet,
                                selectedType: type,
                                totalAmount: amountDifference.abs(),
                                snapshot: walletSnapshot,
                                wallet: wallet,
                              );
                            } else {
                              // Decreasing amount - subtract the difference
                              updateAmount(
                                selectedWallet: newWallet,
                                selectedType: type,
                                totalAmount: amountDifference.abs(),
                                snapshot: walletSnapshot,
                                wallet: wallet,
                                isDelete: true,
                              );
                            }
                          }
                        }

                        // Update the record
                        await record.doc(data.id).set({
                          "title": titleController.value.text,
                          "wallet": selectedWallet,
                          "type": recordType,
                          "total": newTotalAmount,
                          "time": Timestamp.fromDate(selectedDateTime),
                          if (recordType == "Pengeluaran" &&
                              selectedKategori != null)
                            "kategori": selectedKategori
                        });

                        Navigator.pop(context);
                      },
                      child: Text(
                        "Syudah",
                        style: myTextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: IntrinsicHeight(
          // Wrap with IntrinsicHeight to adapt to content height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: BG_COLOR, shape: BoxShape.circle),
                      child: Text(
                        formatTimeOnly(dataMap["time"]),
                        style: myTextStyle(
                          size: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: myTextStyle(size: 18),
                            maxLines: 2, // Allow text to wrap to new lines
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (dataMap["type"] == "Pengeluaran")
                            Text(
                              dataMap["kategori"] ?? "",
                              style: myTextStyle(),
                              maxLines: 2, // Allow text to wrap to new lines
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalAmount,
                    style: myTextStyle(
                      color: (isIncome) ? Colors.green : Colors.red,
                      size: 16,
                    ),
                  ),
                  Text(
                    dataMap["wallet"],
                    style: myTextStyle(fontWeight: FontWeight.normal),
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
          updatedAmount = currentAmount - totalAmount;
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
  required String user,
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
      TextCellValue(data["total"].toString()),
      TextCellValue(formatDateWithTime((data["time"] as Timestamp).toDate())),
    ]);
  }

  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

  Directory? outputDirectory;
  if (Platform.isAndroid && !await Permission.manageExternalStorage.isGranted) {
    await Permission.manageExternalStorage.request();
  }

  String? outputPath = await FilePicker.platform.getDirectoryPath();
  print(outputPath);
  if (outputPath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Penyimpanan dibatalkan."),
        backgroundColor: Colors.red,
      ),
    );
    return; // Stop function here if path is null
  } else {
    outputDirectory = Directory(outputPath);
  }

  DateTime now = DateTime.now();
  String basePath =
      '${outputDirectory.path}/${now.year}-${now.month}-${now.day}-CatatanFinansial$user';

// Selanjutnya proses simpan file seperti biasa
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
