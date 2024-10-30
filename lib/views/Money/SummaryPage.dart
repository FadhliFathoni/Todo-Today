import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatefulWidget {
  SummaryPage({super.key, required this.user});
  final String user;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  int bulanKebelakang = 2;
  String selectedRange = "Per Bulan";

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime dateLimit = DateTime(now.year, now.month - bulanKebelakang, 1);
    var instance = FirebaseFirestore.instance;
    var collection = instance.collection("finance").doc(widget.user);
    var record = collection.collection("record");

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: selectedRange == "Per Bulan",
                  child: Text(
                    "Berapa bulan ke belakang",
                    style: myTextStyle(
                      size: 18,
                      color: PRIMARY_COLOR,
                    ),
                  ),
                  replacement: Text(
                    "Berapa hari ke belakang",
                    style: myTextStyle(
                      size: 18,
                      color: PRIMARY_COLOR,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), backgroundColor: Colors.white),
                      onPressed: () {
                        if (bulanKebelakang > 1) {
                          setState(() {
                            bulanKebelakang--;
                          });
                        }
                      },
                      child: Icon(
                        Icons.remove,
                        color: Colors.red.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      bulanKebelakang.toString(),
                      style: myTextStyle(size: 18, color: PRIMARY_COLOR),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            bulanKebelakang++;
                          });
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.green.withOpacity(0.7),
                        )),
                  ],
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: selectedRange,
                  items: ["Per Bulan", "Per Hari"]
                      .map((range) => DropdownMenuItem(
                            value: range,
                            child: Text(
                              range,
                              style: myTextStyle(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRange = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: record
                .where("type", isEqualTo: "Pengeluaran")
                .where("time",
                    isGreaterThanOrEqualTo: Timestamp.fromDate(dateLimit))
                .orderBy("time", descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.hasError) {
                return Text("Terjadi kesalahan, coba lagi.");
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Container();
              }

              List<ChartData> dataChart = [];
              var docs = snapshot.data!.docs;
              Map<String, double> totals = {};

              for (var doc in docs) {
                var docData = doc.data();
                int total = docData["total"];
                Timestamp timestamp = docData["time"];
                DateTime date = timestamp.toDate();

                // Tentukan format kunci berdasarkan pilihan rentang waktu
                String dateKey = selectedRange == "Per Bulan"
                    ? DateFormat('yyyy-MM').format(date)
                    : DateFormat('yyyy-MM-dd').format(date);

                totals[dateKey] = (totals[dateKey] ?? 0) + total;
              }

              // Ubah data ke dalam objek ChartData
              totals.forEach((key, value) {
                DateTime date = DateFormat(
                        selectedRange == "Per Bulan" ? 'yyyy-MM' : 'yyyy-MM-dd')
                    .parse(key);
                dataChart.add(ChartData(
                    DateFormat(selectedRange == "Per Bulan" ? 'MMMM' : 'dd MMM')
                        .format(date),
                    value));
              });

              return Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    height: MediaQuery.of(context).size.width - 100,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    child: SfCartesianChart(
                      backgroundColor: Colors.white,
                      primaryXAxis: CategoryAxis(
                        labelStyle: myTextStyle(),
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: myTextStyle(),
                        numberFormat:
                            NumberFormat.compactSimpleCurrency(locale: 'id'),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        LineSeries<ChartData, String>(
                          dataSource: dataChart,
                          xValueMapper: (ChartData data, _) => data.month,
                          yValueMapper: (ChartData data, _) => data.total,
                          color: PRIMARY_COLOR,
                          width: 2,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      generateExcel(snapshot: snapshot, context: context);
                    },
                    child: Container(
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file_rounded,
                            color: Colors.green,
                            size: 36,
                          ),
                          Text(
                            "Export to excel",
                            style: myTextStyle(size: 18),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String month;
  final double total;

  ChartData(this.month, this.total);
}
