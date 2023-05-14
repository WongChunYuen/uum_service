import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uum_service/views/screens/userlistscreen.dart';
import '../../serverconfig.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;

import 'verificationlistscreen.dart';
import 'verificationscreen.dart';

class AdminUserScreen extends StatefulWidget {
  final User user;
  final int list;
  const AdminUserScreen({super.key, required this.user, required this.list});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  File? _image;
  var _imageStatus, _verifyStatus;
  var pathAsset = "assets/images/profile.png";
  var val = 50;
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _addressEditingController =
      TextEditingController();
  final TextEditingController _dateregEditingController =
      TextEditingController();
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _imageStatus = widget.user.image.toString();
    _verifyStatus = widget.user.verify.toString();
    print(_verifyStatus);
    _loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.list == 1) {
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (content) => const UserListScreen()));
        } else if (widget.list == 2) {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (content) => const VerificationListScreen()));
        } else if (widget.list == 3) {
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: widget.user.accstatus == "activate"
            ? AppBar(title: const Text("Profile"), actions: [
                PopupMenuButton(itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(
                        value: 0, child: Text("Deactivate")),
                  ];
                }, onSelected: (value) {
                  if (value == 0) {
                    _deactivateDialog();
                  }
                }),
              ])
            : AppBar(title: const Text("Profile"), actions: [
                PopupMenuButton(itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(value: 0, child: Text("Activate")),
                  ];
                }, onSelected: (value) {
                  if (value == 0) {
                    _activateDialog();
                  }
                }),
              ]),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  _imageStatus == 'no'
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipOval(
                            child: Image.asset(
                              pathAsset,
                              height: 150,
                              width: 150,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${ServerConfig.server}/assets/profileimages/${widget.user.id}.png?v=$val",
                              height: 150,
                              width: 150,
                              placeholder: (context, url) =>
                                  const LinearProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported,
                                size: 128,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "ID: ${widget.user.id}",
                    style: const TextStyle(fontSize: 25),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFormField(
                          controller: _nameEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.person),
                            labelText: 'Name',
                          ),
                        ),
                        TextFormField(
                          controller: _emailEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.email),
                            labelText: 'Email',
                          ),
                        ),
                        TextFormField(
                          controller: _phoneEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.phone),
                            labelText: 'Phone',
                          ),
                        ),
                        TextFormField(
                          controller: _addressEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.location_on),
                            labelText: 'Address',
                          ),
                        ),
                        TextFormField(
                          controller: _dateregEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.date_range),
                            labelText: 'Date register',
                          ),
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        _verifyStatus == 'no'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Not Verified",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 20)),
                                ],
                              )
                            : _verifyStatus == 'pending'
                                ? GestureDetector(
                                    onTap: _goVerifyScreen,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text("Pending Verify",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 20)),
                                      ],
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text("Account Verified ",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 20)),
                                      Icon(Icons.verified_rounded,
                                          color: Colors.blue)
                                    ],
                                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method that load user preference
  void _loadUserDetails() {
    if (widget.user.name.toString().isNotEmpty) {
      setState(() {
        _nameEditingController.text = '${widget.user.name}';
        _emailEditingController.text = '${widget.user.email}';
        _phoneEditingController.text = '${widget.user.phone}';
        _addressEditingController.text = '${widget.user.address}';
        _dateregEditingController.text = '${widget.user.regdate}';
      });
    }
  }

  void _deactivateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            "Deactivate ${widget.user.name}'s account",
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
                    _deactivateAccount();
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

  void _deactivateAccount() {
    http.post(Uri.parse("${ServerConfig.server}/php/account_status.php"),
        body: {
          "userid": widget.user.id,
          "deactivate": "deactivate"
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
          widget.user.accstatus = 'deactivate';
        });
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

  void _activateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            "Activate ${widget.user.name}'s account",
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
                    _activateAccount();
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

  void _activateAccount() {
    http.post(Uri.parse("${ServerConfig.server}/php/account_status.php"),
        body: {
          "userid": widget.user.id,
          "activate": "activate"
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
          widget.user.accstatus = 'activate';
        });
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

  void _goVerifyScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => VerificationScreen(user: widget.user)));
  }
}
