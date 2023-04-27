import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../serverconfig.dart';
import 'otpscreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  var screenHeight, screenWidth, cardwitdh;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      cardwitdh = screenWidth;
    } else {
      cardwitdh = 400.00;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Center(
          child: SingleChildScrollView(
              child: SizedBox(
        width: cardwitdh,
        child: Column(
          children: [
            Card(
                elevation: 8,
                margin: const EdgeInsets.all(8),
                child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        const Text(
                          "Find Email",
                          style: TextStyle(
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: _emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val!.isEmpty ||
                                    !val.contains("@") ||
                                    !val.contains(".")
                                ? "enter a valid email"
                                : null,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.email),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ))),
                        const SizedBox(
                          height: 24,
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          minWidth: 115,
                          height: 50,
                          elevation: 10,
                          onPressed: _findUser,
                          color: Theme.of(context).colorScheme.primary,
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ]),
                    ))),
          ],
        ),
      ))),
    );
  }

  void _findUser() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please fill in the credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    String _email = _emailEditingController.text;
    http.post(Uri.parse("${ServerConfig.server}/php/forgot_password.php"),
        body: {"email": _email, "submit": "submit"}).then((response) {
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        print(response.body);
        _sendOTP(_email);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (content) => OTPScreen(
                      name: "",
                      email: _email,
                      phone: "",
                      password: "",
                      screen: "forgot",
                    )));
      } else {
        Fluttertoast.showToast(
            msg: "Email not found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    });
  }

  void _sendOTP(String email) {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/send_otp.php"),
          body: {"email": email, "forgot": "forgot"}).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "OTP sent successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          return;
        } else {
          Fluttertoast.showToast(
              msg: "Fail to sent OTP number",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          return;
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Fail to sent OTP number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
  }
}
