import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../serverconfig.dart';
import '../../models/user.dart';
import 'adminscreen.dart';
import 'buyerscreen.dart';
import 'otpscreen.dart';

// Profile screen for the Homestay Raya application
class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    _imageStatus = widget.user.image;
    _verifyStatus = widget.user.verify;
    _loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        int intId = int.parse(widget.user.id.toString());
        if (intId >= 1 && intId <= 10) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (content) => AdminScreen(user: widget.user)));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (content) => BuyerScreen(user: widget.user)));
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _selectImageDialog,
                    child: _imageStatus == 'no'
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
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.image_not_supported,
                                  size: 128,
                                ),
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
                          onTap:
                              _verifyStatus == 'no' ? _VerifyUserDialog : null,
                          child: _verifyStatus == 'no'
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(" Verify Account",
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20)),
                                  ],
                                )
                              : _verifyStatus == 'pending'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text("Pending Verify",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 20)),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text("Account Verified ",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 20)),
                                        Icon(Icons.verified_rounded,
                                            color: Colors.blue)
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

  _selectImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                    onPressed: () => {
                          Navigator.of(context).pop(),
                          _onGallery(),
                        },
                    icon: const Icon(Icons.browse_gallery),
                    label: const Text("Gallery")),
                TextButton.icon(
                    onPressed: () => {Navigator.of(context).pop(), _onCamera()},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera")),
              ],
            ));
      },
    );
  }

  _onCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    }
  }

  _onGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.indigo,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      _updateProfileImage(_image);
    }
  }

  void _updateProfileImage(image) {
    String base64Image = base64Encode(image!.readAsBytesSync());
    http.post(Uri.parse("${ServerConfig.server}/php/update_profile.php"),
        body: {
          "userid": widget.user.id,
          "image": base64Image,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        User user = User.fromJson(jsondata['data']);
        Fluttertoast.showToast(
            msg: "Image uploaded successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        val = random.nextInt(1000);
        if (widget.user.image == 'no') {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (content) => ProfileScreen(user: user)));
        } else {
          setState(() {});
        }
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
      } else {
        Fluttertoast.showToast(
            msg: "Failed to upload image",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  void _editNameDialog() {
    showDialog(
      barrierDismissible: false,
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
                    setState(() {
                      _nameEditingController.text = '${widget.user.name}';
                    });
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
    http.post(Uri.parse("${ServerConfig.server}/php/update_profile.php"),
        body: {
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
        setState(() {
          _nameEditingController.text = '${widget.user.name}';
        });
      }
    });
  }

  void _editEmailDialog() {
    showDialog(
      barrierDismissible: false,
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
                    String newEmail = _emailEditingController.text;
                    _otpDialog(newEmail);
                  },
                ),
                TextButton(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _emailEditingController.text = '${widget.user.email}';
                    });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _otpDialog(String email) {
    http.post(Uri.parse("${ServerConfig.server}/php/forgot_password.php"),
        body: {"email": email, "submit": "submit"}).then((response) {
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Email have been registered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        setState(() {
          _emailEditingController.text = '${widget.user.email}';
        });
        return;
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: const Text(
                "Verify your email",
                textAlign: TextAlign.center,
              ),
              content: const Text(
                "The OTP number will send to your email address",
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                Center(
                  child: TextButton(
                    child: const Text(
                      "Sure",
                      style: TextStyle(),
                    ),
                    onPressed: () async {
                      _sendOTP(email);
                      Navigator.of(context).pop();
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => OTPScreen(
                                    name: "",
                                    email: email,
                                    phone: "",
                                    password: "",
                                    screen: "update",
                                  )));
                      if (result == 'valid') {
                        _updateEmail(email);
                      } else {
                        setState(() {
                          _emailEditingController.text = '${widget.user.email}';
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _sendOTP(String email) {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/send_otp.php"),
          body: {"email": email, "update": "update"}).then((response) {
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

  void _updateEmail(String newemail) {
    http.post(Uri.parse("${ServerConfig.server}/php/update_profile.php"),
        body: {
          "userid": widget.user.id,
          "newemail": newemail,
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
          widget.user.email = newemail;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        setState(() {
          _emailEditingController.text = '${widget.user.email}';
        });
      }
    });
  }

  void _editPhoneDialog() {
    showDialog(
      barrierDismissible: false,
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
                    setState(() {
                      _phoneEditingController.text = '${widget.user.phone}';
                    });
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
    http.post(Uri.parse("${ServerConfig.server}/php/update_profile.php"),
        body: {
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
        setState(() {
          _phoneEditingController.text = '${widget.user.phone}';
        });
      }
    });
  }

  void _editAddressDialog() {
    showDialog(
      barrierDismissible: false,
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
                    setState(() {
                      _addressEditingController.text = '${widget.user.address}';
                    });
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
    http.post(Uri.parse("${ServerConfig.server}/php/update_profile.php"),
        body: {
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
        setState(() {
          _addressEditingController.text = '${widget.user.address}';
        });
      }
    });
  }

  void _VerifyUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Verify Account",
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "You need to take your MyKad picture and your selfie to verify your account",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Sure",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _onCameraVerify();
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

  _onCameraVerify() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImageMyKad();
    }
  }

  Future<void> cropImageMyKad() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio3x2,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop MyKad',
            toolbarColor: Colors.indigo,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      _onCameraSelfie(_image);
    }
  }

  _onCameraSelfie(imageMyKad) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImageSelfie(imageMyKad);
    }
  }

  Future<void> cropImageSelfie(imageMyKad) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Selfie',
            toolbarColor: Colors.indigo,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      _updateVerification(imageMyKad, _image);
    }
  }

  void _updateVerification(imageMyKad, imageSelfie) {
    String base64ImageMyKad = base64Encode(imageMyKad!.readAsBytesSync());
    String base64ImageSelfie = base64Encode(imageSelfie!.readAsBytesSync());
    http.post(Uri.parse("${ServerConfig.server}/php/update_profile.php"),
        body: {
          "userid": widget.user.id,
          "imageMyKad": base64ImageMyKad,
          "imageSelfie": base64ImageSelfie,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        User user = User.fromJson(jsondata['data']);
        Fluttertoast.showToast(
            msg: "Uploaded successfully. Please wait admin to approve.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        val = random.nextInt(1000);
        if (widget.user.verify == 'no') {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (content) => ProfileScreen(user: user)));
        } else {
          setState(() {});
        }
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
      } else {
        Fluttertoast.showToast(
            msg: "Failed to upload MyKad and Selfie",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }
}
