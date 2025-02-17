import 'package:flutter/material.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/FinancialPage.dart';
import 'package:todo_today/views/Money/SummaryPage.dart';

class MainFinancial extends StatefulWidget {
  const MainFinancial({super.key, required this.user});

  final String user;

  @override
  State<MainFinancial> createState() => _MainFinancialState();
}

class _MainFinancialState extends State<MainFinancial> {
  int currentIndex = 0;
  Widget? buildBody() {
    switch (currentIndex) {
      case 0:
        return Financialpage(
          user: widget.user,
        );
      case 1:
        return SummaryPage(
          user: widget.user,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BG_COLOR,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: PRIMARY_COLOR,
        ),
        centerTitle: true,
        title: Text(
          "Catatan Finansial",
          style: TextStyle(fontFamily: PRIMARY_FONT, color: PRIMARY_COLOR),
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(fontFamily: PRIMARY_FONT),
          unselectedLabelStyle: TextStyle(fontFamily: PRIMARY_FONT),
          selectedItemColor: PRIMARY_COLOR,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded), label: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: ""),
          ]),
    );
  }
}
