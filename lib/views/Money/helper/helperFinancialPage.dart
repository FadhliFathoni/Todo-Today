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

bool isTransferRecord({
  required String? type,
  required String? category,
}) {
  return type?.toLowerCase() == "pengeluaran" &&
      category?.toLowerCase() == "transfer";
}

String? getTransferDestinationWallet(Map<String, dynamic> dataMap) {
  final destination = dataMap["walletTujuan"]?.toString().trim();
  if (destination == null || destination.isEmpty) {
    return null;
  }
  return destination;
}

String? getTransferPairId(Map<String, dynamic> dataMap) {
  final pairId = dataMap["transferPairId"]?.toString().trim();
  if (pairId == null || pairId.isEmpty) {
    return null;
  }
  return pairId;
}

bool isLinkedTransferRecord(Map<String, dynamic> dataMap) {
  return getTransferPairId(dataMap) != null;
}

Future<Map<String, QueryDocumentSnapshot<Map<String, dynamic>>?>>
    getTransferPairDocs({
  required CollectionReference<Map<String, dynamic>> record,
  required String pairId,
}) async {
  final pairSnapshot =
      await record.where("transferPairId", isEqualTo: pairId).get();

  QueryDocumentSnapshot<Map<String, dynamic>>? expenseDoc;
  QueryDocumentSnapshot<Map<String, dynamic>>? incomeDoc;

  for (final doc in pairSnapshot.docs) {
    final data = doc.data();
    final role = data["transferRole"]?.toString().toLowerCase();
    final type = data["type"]?.toString().toLowerCase();

    if (role == "expense" || type == "pengeluaran") {
      expenseDoc = doc;
    } else if (role == "income" || type == "pemasukan") {
      incomeDoc = doc;
    }
  }

  return {
    "expense": expenseDoc,
    "income": incomeDoc,
  };
}

bool isFinancialRecordFormValid({
  required String selectedType,
  required String? selectedKategori,
  required String? selectedWallet,
  required String? selectedDestinationWallet,
  required String totalText,
}) {
  final totalAmount = convertRupiahToInt(totalText);
  if (totalAmount <= 0 || selectedWallet == null || selectedWallet.isEmpty) {
    return false;
  }

  if (selectedType == "pengeluaran") {
    if (selectedKategori == null || selectedKategori.trim().isEmpty) {
      return false;
    }

    if (selectedKategori.trim().toLowerCase() == "transfer") {
      if (selectedDestinationWallet == null ||
          selectedDestinationWallet.isEmpty) {
        return false;
      }

      if (selectedDestinationWallet == selectedWallet) {
        return false;
      }
    }
  }

  return true;
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
    final isTransfer = isTransferRecord(
      type: dataMap["type"]?.toString(),
      category: dataMap["kategori"]?.toString(),
    );
    final destinationWallet = getTransferDestinationWallet(dataMap);
    final transferPairId = getTransferPairId(dataMap);
    final title = dataMap["title"] ?? dataMap["type"];
    final totalAmount = formatToRupiah(
      dataMap["total"] * (isIncome ? 1 : -1),
    );

    return GestureDetector(
      onLongPress: () async {
        var userDoc = record.parent?.parent;
        var userId = userDoc?.id ?? "";
        var instance = FirebaseFirestore.instance;
        var collection = instance.collection("finance").doc(userId);
        var kategori = collection.collection("kategori");
        QueryDocumentSnapshot<Map<String, dynamic>>? transferExpenseDoc;
        QueryDocumentSnapshot<Map<String, dynamic>>? transferIncomeDoc;

        if (transferPairId != null) {
          final pairDocs = await getTransferPairDocs(
            record: record,
            pairId: transferPairId,
          );
          transferExpenseDoc = pairDocs["expense"];
          transferIncomeDoc = pairDocs["income"];
        }

        final isLinkedTransferPair =
            transferExpenseDoc != null && transferIncomeDoc != null;
        final primaryDataMap =
            isLinkedTransferPair ? transferExpenseDoc.data() : dataMap;
        final linkedIncomeDataMap =
            isLinkedTransferPair ? transferIncomeDoc.data() : null;

        var titleController = TextEditingController(
          text: primaryDataMap["title"]?.toString() ?? "",
        );
        var totalController = TextEditingController(
          text: formatToRupiah(primaryDataMap["total"]),
        );
        var kategoriController = TextEditingController();

        DateTime selectedDateTime =
            (primaryDataMap["time"] as Timestamp).toDate();
        String? selectedKategori =
            isLinkedTransferPair ? "Transfer" : dataMap["kategori"];
        String? selectedWallet = primaryDataMap["wallet"];
        String? selectedDestinationWallet = isLinkedTransferPair
            ? linkedIncomeDataMap == null
                ? null
                : linkedIncomeDataMap["wallet"]?.toString()
            : destinationWallet;
        String recordType =
            isLinkedTransferPair ? "Pengeluaran" : dataMap["type"];

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
            builder: (context, dialogSetState) {
              return AlertDialog(
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
                        onChanged: (data) {
                          dialogSetState(() {});
                        },
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
                          final formattedAmount = amount == 0 && data.isEmpty
                              ? ""
                              : formatToRupiah(amount);
                          dialogSetState(() {
                            totalController.value = TextEditingValue(
                              text: formattedAmount,
                              selection: TextSelection.fromPosition(
                                TextPosition(offset: formattedAmount.length),
                              ),
                            );
                          });
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

                            Set<String> seenCategories = {};
                            List<DropdownMenuItem<String>> categoryItems = [];

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

                            if (!seenCategories.contains("Transfer")) {
                              seenCategories.add("Transfer");
                              categoryItems.add(
                                DropdownMenuItem<String>(
                                  value: "Transfer",
                                  child: Text(
                                    "Transfer",
                                    style: myTextStyle(),
                                  ),
                                ),
                              );
                            }

                            String? trimmedSelectedKategori =
                                selectedKategori?.trim();
                            if (trimmedSelectedKategori != null &&
                                trimmedSelectedKategori.isNotEmpty &&
                                !seenCategories
                                    .contains(trimmedSelectedKategori)) {
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

                            final itemValues = categoryItems
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
                              items: categoryItems,
                              value: finalValidSelectedKategori,
                              onChanged: (value) {
                                dialogSetState(() {
                                  selectedKategori = value;
                                  if (value?.toLowerCase() != "transfer") {
                                    selectedDestinationWallet = null;
                                  }
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
                      if (recordType == "Pengeluaran")
                        const SizedBox(height: 12),
                      if (recordType == "Pengeluaran" &&
                          isTransferRecord(
                            type: recordType,
                            category: selectedKategori,
                          ))
                        StreamBuilder(
                          stream: wallet.snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }

                            if (selectedDestinationWallet == selectedWallet) {
                              selectedDestinationWallet = null;
                            }

                            var destinationWalletItems = snapshot.data!.docs
                                .where((doc) => doc.id != selectedWallet)
                                .map<DropdownMenuItem<String>>((doc) {
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text(
                                  doc['name'],
                                  style: myTextStyle(),
                                ),
                              );
                            }).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Wallet tujuan",
                                  style: myTextStyle(),
                                ),
                                DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: PRIMARY_COLOR,
                                  style: myTextStyle(),
                                  items: destinationWalletItems,
                                  value: selectedDestinationWallet,
                                  onChanged: (value) {
                                    dialogSetState(() {
                                      selectedDestinationWallet = value;
                                    });
                                  },
                                  hint: Text(
                                    "Pilih Wallet Tujuan",
                                    style: myTextStyle(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                      StreamBuilder(
                        stream: wallet.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }

                          if (selectedDestinationWallet == selectedWallet) {
                            selectedDestinationWallet = null;
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
                                if (selectedDestinationWallet == value) {
                                  selectedDestinationWallet = null;
                                }
                              });
                            },
                            hint: Text(
                              isTransferRecord(
                                type: recordType,
                                category: selectedKategori,
                              )
                                  ? "Pilih Wallet Asal"
                                  : "Pilih Wallet",
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
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
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
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (isLinkedTransferPair) {
                            final batch = FirebaseFirestore.instance.batch();
                            batch.delete(transferExpenseDoc!.reference);
                            batch.delete(transferIncomeDoc!.reference);
                            await batch.commit();
                            updateTransferAmount(
                              sourceWallet: transferExpenseDoc["wallet"]
                                  .toString()
                                  .toLowerCase(),
                              destinationWallet: transferIncomeDoc["wallet"]
                                  .toString()
                                  .toLowerCase(),
                              totalAmount: transferExpenseDoc["total"],
                              snapshot: snapshot,
                              wallet: wallet,
                              isDelete: true,
                            );
                          } else {
                            await record.doc(data.id).delete();
                            if (isTransfer && destinationWallet != null) {
                              updateTransferAmount(
                                sourceWallet:
                                    dataMap["wallet"].toString().toLowerCase(),
                                destinationWallet:
                                    destinationWallet.toLowerCase(),
                                totalAmount: dataMap["total"],
                                snapshot: snapshot,
                                wallet: wallet,
                                isDelete: true,
                              );
                            } else {
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
                            }
                          }
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
                      final isSubmitEnabled = isFinancialRecordFormValid(
                        selectedType: isLinkedTransferPair
                            ? "pengeluaran"
                            : recordType.toLowerCase(),
                        selectedKategori: selectedKategori,
                        selectedWallet: selectedWallet,
                        selectedDestinationWallet: selectedDestinationWallet,
                        totalText: totalController.value.text,
                      );

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubmitEnabled
                              ? PRIMARY_COLOR
                              : Colors.grey.shade400,
                        ),
                        onPressed: isSubmitEnabled
                            ? () async {
                                if (!walletSnapshot.hasData) return;

                                int newTotalAmount = convertRupiahToInt(
                                    totalController.value.text);
                                String newWallet =
                                    selectedWallet!.toLowerCase();
                                String type = recordType.toLowerCase();
                                final oldDestinationWallet =
                                    getTransferDestinationWallet(dataMap)
                                        ?.toLowerCase();
                                final newDestinationWallet =
                                    selectedDestinationWallet?.toLowerCase();
                                final wasTransfer = isTransferRecord(
                                  type: recordType,
                                  category: dataMap["kategori"]?.toString(),
                                );
                                final isNowTransfer = isTransferRecord(
                                  type: recordType,
                                  category: selectedKategori,
                                );

                                if (isLinkedTransferPair) {
                                  updateTransferAmount(
                                    sourceWallet: transferExpenseDoc!["wallet"]
                                        .toString()
                                        .toLowerCase(),
                                    destinationWallet:
                                        transferIncomeDoc!["wallet"]
                                            .toString()
                                            .toLowerCase(),
                                    totalAmount: transferExpenseDoc["total"],
                                    snapshot: walletSnapshot,
                                    wallet: wallet,
                                    isDelete: true,
                                  );
                                } else if (wasTransfer &&
                                    oldDestinationWallet != null) {
                                  updateTransferAmount(
                                    sourceWallet: dataMap["wallet"]
                                        .toString()
                                        .toLowerCase(),
                                    destinationWallet: oldDestinationWallet,
                                    totalAmount: dataMap["total"],
                                    snapshot: walletSnapshot,
                                    wallet: wallet,
                                    isDelete: true,
                                  );
                                } else {
                                  updateAmount(
                                    selectedWallet: dataMap["wallet"]
                                        .toString()
                                        .toLowerCase(),
                                    selectedType: type,
                                    totalAmount: dataMap["total"],
                                    snapshot: walletSnapshot,
                                    wallet: wallet,
                                    isDelete: true,
                                  );
                                }

                                await Future.delayed(
                                  Duration(milliseconds: 100),
                                );

                                var freshSnapshot = await wallet.get();
                                var freshWalletSnapshot = AsyncSnapshot<
                                    QuerySnapshot<
                                        Map<String, dynamic>>>.withData(
                                  ConnectionState.done,
                                  freshSnapshot,
                                );

                                if (newTotalAmount != 0) {
                                  if (isNowTransfer &&
                                      newDestinationWallet != null) {
                                    updateTransferAmount(
                                      sourceWallet: newWallet,
                                      destinationWallet: newDestinationWallet,
                                      totalAmount: newTotalAmount,
                                      snapshot: freshWalletSnapshot,
                                      wallet: wallet,
                                    );
                                  } else {
                                    updateAmount(
                                      selectedWallet: newWallet,
                                      selectedType: type,
                                      totalAmount: newTotalAmount,
                                      snapshot: freshWalletSnapshot,
                                      wallet: wallet,
                                    );
                                  }
                                }

                                final trimmedTitle =
                                    titleController.value.text.trim();

                                if (isLinkedTransferPair &&
                                    selectedDestinationWallet != null) {
                                  final batch =
                                      FirebaseFirestore.instance.batch();
                                  batch.set(transferExpenseDoc!.reference, {
                                    "title": trimmedTitle.isEmpty
                                        ? "Transfer"
                                        : trimmedTitle,
                                    "wallet": selectedWallet,
                                    "type": "Pengeluaran",
                                    "total": newTotalAmount,
                                    "time":
                                        Timestamp.fromDate(selectedDateTime),
                                    "kategori": "Transfer",
                                    "transferPairId": transferPairId,
                                    "transferRole": "expense",
                                  });
                                  batch.set(transferIncomeDoc!.reference, {
                                    "title": trimmedTitle.isEmpty
                                        ? "Transfer"
                                        : trimmedTitle,
                                    "wallet": selectedDestinationWallet,
                                    "type": "Pemasukan",
                                    "total": newTotalAmount,
                                    "time":
                                        Timestamp.fromDate(selectedDateTime),
                                    "transferPairId": transferPairId,
                                    "transferRole": "income",
                                  });
                                  await batch.commit();
                                } else {
                                  await record.doc(data.id).set({
                                    "title":
                                        trimmedTitle.isEmpty && isNowTransfer
                                            ? "Transfer"
                                            : trimmedTitle,
                                    "wallet": selectedWallet,
                                    "type": recordType,
                                    "total": newTotalAmount,
                                    "time":
                                        Timestamp.fromDate(selectedDateTime),
                                    if (recordType == "Pengeluaran" &&
                                        selectedKategori != null)
                                      "kategori": selectedKategori,
                                  });
                                }

                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          "Syudah",
                          style: myTextStyle(
                            color:
                                isSubmitEnabled ? Colors.white : Colors.white70,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (dataMap["type"] == "Pengeluaran")
                            Text(
                              dataMap["kategori"] ?? "",
                              style: myTextStyle(),
                              maxLines: 2,
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
                    dataMap["wallet"] ?? "",
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
  if (numericString.isEmpty) {
    return 0;
  }
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

  if (walletDoc != null) {
    int currentAmount = walletDoc["amount"] ?? 0;
    int updatedAmount = 0;

    if (isDelete == true) {
      if (selectedType == "pengeluaran") {
        updatedAmount = selectedWallet == "kebutuhan"
            ? currentAmount - totalAmount
            : currentAmount + totalAmount;
      } else {
        if (selectedWallet == "kebutuhan") {
          int currentAmount = walletDoc["maxAmount"] ?? 0;
          updatedAmount = currentAmount - totalAmount;
        } else {
          updatedAmount = currentAmount - totalAmount;
        }
      }
    } else {
      if (selectedType == "pengeluaran") {
        updatedAmount = selectedWallet == "kebutuhan"
            ? currentAmount + totalAmount
            : currentAmount - totalAmount;
      } else {
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

void updateTransferAmount({
  required String sourceWallet,
  required String destinationWallet,
  required int totalAmount,
  required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  required CollectionReference<Map<String, dynamic>> wallet,
  bool? isDelete,
}) {
  updateAmount(
    selectedWallet: sourceWallet,
    selectedType: "pengeluaran",
    totalAmount: totalAmount,
    snapshot: snapshot,
    wallet: wallet,
    isDelete: isDelete,
  );

  updateAmount(
    selectedWallet: destinationWallet,
    selectedType: "pemasukan",
    totalAmount: totalAmount,
    snapshot: snapshot,
    wallet: wallet,
    isDelete: isDelete,
  );
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
