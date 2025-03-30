import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_today/Component/PrimaryTextField.dart';
import 'package:todo_today/main.dart';
import 'package:todo_today/views/Money/FinancialPage.dart';
import 'package:todo_today/views/Money/SummaryPage.dart';
import 'package:todo_today/views/Money/helper/helperFinancialPage.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginFinansial extends StatefulWidget {
  const LoginFinansial({Key? key}) : super(key: key);

  @override
  State<LoginFinansial> createState() => _LoginFinansialState();
}

class _LoginFinansialState extends State<LoginFinansial> {
  double height(BuildContext context) => MediaQuery.of(context).size.height;
  double width(BuildContext context) => MediaQuery.of(context).size.width;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool showPassword = false;

  void openWhatsApp() async {
    final url = Uri.parse("https://wa.me/6285794766478?text=oyyy+dil");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }

  void checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') == null) {
      print("ini null temanku");
    } else {
      // await initializeService();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return MainFinancial(user: prefs.getString('user')!);
      }));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  void login({required String username, required String password}) async {
    var instance = FirebaseFirestore.instance;
    var docRef = instance.collection("anomali").doc(username);

    var docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      var data = docSnapshot.data();
      var existingPassword = data?["password"];
      if (existingPassword == password) {
        print("Password sama");
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString("user", username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainFinancial(user: username),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 82,
                ),
                Text(
                  "Lho password salah",
                  style: myTextStyle(color: PRIMARY_COLOR),
                ),
              ],
            ),
          ),
        );
      }
      print("Password: $existingPassword");
      print("Password Inputed: $password");
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close,
                color: Colors.red,
                size: 82,
              ),
              Text(
                "Akunnya gaada",
                style: myTextStyle(color: PRIMARY_COLOR),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Color.fromARGB(255, 139, 139, 139),
          height: height(context),
          width: width(context),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: width(context) * 0.7,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 14),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontFamily: PRIMARY_FONT,
                              color: PRIMARY_COLOR,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        PrimaryTextField(
                          controller: usernameController,
                          hintText: "Username",
                          onChanged: (var data) {},
                        ),
                        PrimaryTextField(
                          controller: passwordController,
                          hintText: "Password",
                          onChanged: (var data) {},
                          obscureText: !showPassword,
                          maxLine: 1,
                          suffixWidget: IconButton(
                            icon: Icon(
                              (showPassword == true)
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.remove_red_eye,
                              color: PRIMARY_COLOR,
                            ),
                            onPressed: () {
                              showPassword = !showPassword;
                              setState(() {});
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              openWhatsApp();
                            },
                            style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return PRIMARY_COLOR.withOpacity(
                                        0.2); // Ganti warna splash di sini
                                  }
                                  return null;
                                },
                              ),
                            ),
                            child: Text(
                              "Pdil call center",
                              style: myTextStyle(color: PRIMARY_COLOR),
                            ),
                          ),
                        ),
                        Container(
                          width: 120,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PRIMARY_COLOR,
                            ),
                            onPressed: () {
                              login(
                                username: usernameController.text,
                                password: passwordController.text,
                              );
                            },
                            child: Text(
                              "Gasss",
                              style: myTextStyle(color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ]),
                ),
              )
            ],
          )),
    );
  }
}

class MainFinancial extends StatefulWidget {
  const MainFinancial({super.key, required this.user});

  final String user;

  @override
  State<MainFinancial> createState() => _MainFinancialState();
}

class _MainFinancialState extends State<MainFinancial> {
  int currentIndex = 0;

  @override
  void initState() {
    if (widget.user == "") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Sorry guys ngga bisa masuk"),
        ),
      );
    }
    super.initState();
  }

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
