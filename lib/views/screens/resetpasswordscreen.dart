import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../serverconfig.dart';
import 'loginscreen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _pass1EditingController = TextEditingController();
  final TextEditingController _pass2EditingController = TextEditingController();

  bool _passwordVisible = true;
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
        title: const Text("Reset Password"),
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
                          "Reset Your Password",
                          style: TextStyle(
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: _pass1EditingController,
                            keyboardType: TextInputType.visiblePassword,
                            validator: (val) =>
                                validatePassword(val.toString()),
                            obscureText: _passwordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(),
                              icon: const Icon(Icons.password),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(width: 1.0),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            )),
                        TextFormField(
                            controller: _pass2EditingController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _passwordVisible,
                            decoration: InputDecoration(
                              labelText: 'Re-Password',
                              labelStyle: const TextStyle(),
                              icon: const Icon(Icons.password),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(width: 1.0),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            )),
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
                            'Reset',
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

  String? validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{10,}$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Required uppercase letter and minimum 10 characters';
      } else {
        return null;
      }
    }
  }

  void _findUser() {
    String _passa = _pass1EditingController.text;
    String _passb = _pass2EditingController.text;

    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the registration form first!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    if (_passa != _passb) {
      Fluttertoast.showToast(
          msg: "Your password is not same!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    http.post(Uri.parse("${ServerConfig.server}/php/forgot_password.php"), body: {
      "reEmail": widget.email,
      "password": _passa,
      "reset": "reset"
    }).then((response) {
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: const Text(
                "Reset successfully",
                textAlign: TextAlign.center,
              ),
              content: const Text(
                "Go back to login",
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                Center(
                  child: TextButton(
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => const LoginScreen()));
                    },
                  ),
                ),
              ],
            );
          },
        );
      } else {
        Fluttertoast.showToast(
            msg: "Please try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    });
  }
}
