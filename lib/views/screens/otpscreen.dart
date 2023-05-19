import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../serverconfig.dart';
import 'resetpasswordscreen.dart';

class OTPScreen extends StatefulWidget {
  final String name, email, phone, password, screen;
  const OTPScreen(
      {super.key,
      required this.name,
      required this.email,
      required this.phone,
      required this.password,
      required this.screen});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpEditingController = TextEditingController();

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
    return WillPopScope(
      onWillPop: () async {
        String screen = widget.screen;
        if (screen == "update") {
          Navigator.pop(context, 'back');
        } else {
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("OTP"),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/10.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: SingleChildScrollView(
                  child: SizedBox(
            width: cardwitdh,
            child: Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        const Text(
                          "Enter OTP number",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                            controller: _otpEditingController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val!.isEmpty
                                ? "Please enter an OTP number"
                                : null,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                                labelText: 'OTP number',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                icon: const Icon(
                                  Icons.system_security_update_good,
                                  color: Colors.white,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(20.0),
                                ))),
                        const SizedBox(
                          height: 30,
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          minWidth: cardwitdh,
                          height: 50,
                          elevation: 10,
                          onPressed: _submitOTP,
                          color: Theme.of(context).colorScheme.primary,
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ]),
                    )),
                const SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: _sendOTP,
                  child: const Text(
                    "Send OTP again",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ))),
        ),
      ),
    );
  }

  void _submitOTP() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please enter an OTP number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    String _otp = _otpEditingController.text;

    http.post(Uri.parse("${ServerConfig.server}/php/submit_otp.php"), body: {
      "email": widget.screen == "forgot" ? widget.email : "admin01@gmail.com",
      "otp": _otp,
      "submit": "submit"
    }).then((response) {
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        print(response.body);
        if (widget.screen == "register") {
          _registerUser(
              widget.name, widget.email, widget.phone, widget.password);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else if (widget.screen == "forgot") {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (content) =>
                      ResetPasswordScreen(email: widget.email)));
        } else if (widget.screen == "update") {
          Navigator.pop(context, 'valid');
        }
      } else {
        Fluttertoast.showToast(
            msg: "Invalid OTP number",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    });
  }

  void _registerUser(String name, String email, String phone, String pass) {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/register_user.php"),
          body: {
            "name": name,
            "email": email,
            "phone": phone,
            "password": pass,
            "register": "register"
          }).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "Register success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);

          return;
        } else {
          Fluttertoast.showToast(
              msg: "Fail to register",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          return;
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Fail to register",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
  }

  void _sendOTP() {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/send_otp.php"), body: {
        "email": widget.email,
        widget.screen: widget.screen,
        "resend": "resend"
      }).then((response) {
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
