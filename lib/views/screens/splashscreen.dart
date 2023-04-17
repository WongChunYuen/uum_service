import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../serverconfig.dart';
import '../../models/user.dart';
import 'adminscreen.dart';
import 'buyerscreen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Auto Login after when the splash screen is running
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Image.asset('assets/images/logo.png', scale: 0.9),
          const SizedBox(
            height: 30,
          ),
          const Text("UUM SERVICE",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 50,
          ),
          const SizedBox(
            height: 25,
            width: 100,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(
            height: 140,
          ),
          const Text("Version 1.0"),
          const SizedBox(
            height: 100,
          ),
        ]),
      ),
    );
  }

  // A method to auto login and navigate to the Main screen
  Future<void> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _email = (prefs.getString('email')) ?? '';
    String _pass = (prefs.getString('pass')) ?? '';
    // If the shared_preferences is not empty then login
    if (_email.isNotEmpty) {
      http.post(Uri.parse("${ServerConfig.server}/php/login_user.php"), body: {
        "email": _email,
        "password": _pass,
        "login": "login"
      }).then((response) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if (response.statusCode == 200 && jsonResponse['status'] == "success") {
          User user = User.fromJson(jsonResponse['data']);
          int intId = int.parse(user.id.toString());
          if (intId >= 1 && intId <= 10) {
            Timer(
                const Duration(seconds: 3),
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (content) => AdminScreen(user: user))));
          } else {
            Timer(
                const Duration(seconds: 3),
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (content) => BuyerScreen(user: user))));
          }
        } else {
          User user = User(
              id: "0",
              accstatus: "activate",
              email: "unregistered",
              image: "no",
              name: "unregistered",
              address: "na",
              phone: "0123456789",
              verify: "no",
              regdate: "0");
          Timer(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => BuyerScreen(user: user))));
        }
      });
    } else {
      User user = User(
          id: "0",
          accstatus: "activate",
          email: "unregistered",
          image: "no",
          name: "unregistered",
          address: "na",
          phone: "0123456789",
          verify: "no",
          regdate: "0");
      Timer(
          const Duration(seconds: 3),
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (content) => BuyerScreen(user: user))));
    }
  }
}
