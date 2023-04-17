import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../serverconfig.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;
import 'adminuserscreen.dart';

class VerificationScreen extends StatefulWidget {
  final User user;
  const VerificationScreen({super.key, required this.user});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late double screenWidth;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify User"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MyKad: ",
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 8,
              ),
              GestureDetector(
                  onTap: null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      "${ServerConfig.server}/assets/userverification/MyKad_${widget.user.id}.png",
                      fit: BoxFit.cover,
                    ),
                  )),
              const SizedBox(
                height: 12,
              ),
              const Text(
                "Selfie: ",
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 8,
              ),
              GestureDetector(
                  onTap: null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      "${ServerConfig.server}/assets/userverification/Selfie_${widget.user.id}.png",
                      fit: BoxFit.cover,
                    ),
                  )),
              const SizedBox(
                height: 12,
              ),
              Center(
                  child: SizedBox(
                width: screenWidth,
                height: 50,
                child: ElevatedButton(
                  onPressed: _approveVerificationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _approveVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Approve user veirification",
            textAlign: TextAlign.center,
          ),
          content: const Text("Are you sure?", textAlign: TextAlign.center),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Yes",
                    style: TextStyle(),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _approveVerification();
                  },
                ),
                TextButton(
                  child: const Text(
                    "No",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _approveVerification() {
    http.post(Uri.parse("${ServerConfig.server}/php/account_status.php"),
        body: {
          "userid": widget.user.id,
          "approve": "approve"
        }).then((response) {
      print(response.body);
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        setState(() {
          widget.user.verify = 'yes';
        });
        Navigator.of(context).pop();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (content) => AdminUserScreen(
                      user: widget.user,
                      list: 2,
                    )));
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }
}
