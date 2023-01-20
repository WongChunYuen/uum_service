import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../models/user.dart';

// Profile screen for the Homestay Raya application
class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _addressEditingController =
      TextEditingController();
  final TextEditingController _dateregEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  child: const SizedBox(
                    height: 150,
                    child: CircleAvatar(
                      radius: 90.0,
                      backgroundImage: AssetImage("assets/images/profile.png"),
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
                      InkWell(
                        onTap: () {
                          _editNameDialog();
                        },
                        child: TextFormField(
                          controller: _nameEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.person),
                              labelText: 'Name',
                              suffixIcon: Icon(Icons.edit)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _editEmailDialog();
                        },
                        child: TextFormField(
                          controller: _emailEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.email),
                            labelText: 'Email',
                            suffixIcon: Icon(Icons.edit),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _editPhoneDialog();
                        },
                        child: TextFormField(
                          controller: _phoneEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.phone),
                            labelText: 'Phone',
                            suffixIcon: Icon(Icons.edit),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _editAddressDialog();
                        },
                        child: TextFormField(
                          controller: _addressEditingController,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.location_on),
                            labelText: 'Address',
                            suffixIcon: Icon(Icons.edit),
                          ),
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
                      GestureDetector(
                        onTap: _openCamara,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Verify Account ",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20)),
                            Icon(Icons.verified_rounded, color: Colors.blue)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method that load user preference
  void _loadUserDetails() {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String name = '${widget.user.name}';
    // String email = '${widget.user.email}';
    // String phone = '${widget.user.phone}';
    // String address = '${widget.user.address}';
    // String datereg = '${widget.user.regdate}';
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

  void _editNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit name"),
          content: TextFormField(
            controller: _nameEditingController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Save",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    String newname = _nameEditingController.text;
                    _updateName(newname);
                  },
                ),
                TextButton(
                  child: const Text(
                    "Cancel",
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

  void _updateName(String newname) {
    http.post(Uri.parse("${Config.server}/php/update_profile.php"), body: {
      "userid": widget.user.id,
      "newname": newname,
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
          widget.user.name = newname;
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

  void _editEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit email"),
          content: TextFormField(
            controller: _emailEditingController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Save",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    // Edit method
                  },
                ),
                TextButton(
                  child: const Text(
                    "Cancel",
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

  void _editPhoneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit phone"),
          content: TextFormField(
            controller: _phoneEditingController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Save",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    String newPhone = _phoneEditingController.text;
                    _updatePhone(newPhone);
                  },
                ),
                TextButton(
                  child: const Text(
                    "Cancel",
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

  void _updatePhone(String newphone) {
    http.post(Uri.parse("${Config.server}/php/update_profile.php"), body: {
      "userid": widget.user.id,
      "newphone": newphone,
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
          widget.user.phone = newphone;
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

  void _editAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit address"),
          content: TextFormField(
            controller: _addressEditingController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Save",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    String newAddress = _addressEditingController.text;
                    _updateAddress(newAddress);
                  },
                ),
                TextButton(
                  child: const Text(
                    "Cancel",
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

  void _updateAddress(String newaddress) {
    http.post(Uri.parse("${Config.server}/php/update_profile.php"), body: {
      "userid": widget.user.id,
      "newaddress": newaddress,
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
          widget.user.phone = newaddress;
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

  void _openCamara() {}
}
