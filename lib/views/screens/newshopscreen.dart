import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'sellerscreeen.dart';

class NewShopScreen extends StatefulWidget {
  final User user;

  const NewShopScreen({
    super.key,
    required this.user,
  });

  @override
  State<NewShopScreen> createState() => _NewShopScreenState();
}

class _NewShopScreenState extends State<NewShopScreen> {
  final TextEditingController _snameEditingController = TextEditingController();
  final TextEditingController _sdescEditingController = TextEditingController();
  final TextEditingController _saddrEditingController = TextEditingController();
  final TextEditingController _sbankaccEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectBank = "Please select a Bank";
  List<String> bankList = [
    "Please select a Bank",
    "Bank 1",
    "Bank 2",
    "Bank 3",
    "MayBank",
  ];

  File? _image;
  final List<File> _imageList = [];
  var pathAsset = "assets/images/camera.png";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("New Shop")),
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 16,
            ),
            Center(
              child: SizedBox(
                height: 230,
                child: PageView.builder(
                    itemCount: _imageList.length + 1,
                    controller: PageController(viewportFraction: 0.8),
                    itemBuilder: (BuildContext context, int index) {
                      return Transform.scale(
                        scale: 1,
                        child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: GestureDetector(
                              onTap: () => _manageImageDialog(index),
                              child: Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: _imageList.length > index
                                      ? FileImage(_imageList[index])
                                          as ImageProvider
                                      : AssetImage(pathAsset),
                                  fit: BoxFit.cover,
                                )),
                              ),
                            )),
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Create New Shop",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _snameEditingController,
                      validator: (val) => val!.isEmpty || (val.length < 4)
                          ? "Shop name must be longer than 3"
                          : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Shop Name',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.home),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _sdescEditingController,
                      validator: (val) => val!.isEmpty || (val.length < 10)
                          ? "Shop description must be longer than 10"
                          : null,
                      maxLines: 4,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Shop Description',
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.description,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  DropdownButtonFormField(
                    value: selectBank,
                    decoration: const InputDecoration(
                        labelText: 'Bank',
                        labelStyle: TextStyle(),
                        icon: Icon(Icons.add_card),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        )),
                    onChanged: (newValue) {
                      setState(() {
                        selectBank = newValue.toString();
                      });
                    },
                    items: bankList.map((selectBank) {
                      return DropdownMenuItem(
                          value: selectBank,
                          child: Text(
                            selectBank,
                          ));
                    }).toList(),
                  ),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _sbankaccEditingController,
                      validator: (val) =>
                          val!.isEmpty ? "Please enter bank account" : null,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Bank Account',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.add_card),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _saddrEditingController,
                      validator: (val) =>
                          val!.isEmpty ? "Please enter shop address" : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Shop Address',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.place),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      child: const Text(
                        'Create Shop',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () => {
                        _newShopDialog(),
                      },
                    ),
                  ),
                ]),
              ),
            )
          ]),
        ));
  }

  void _newShopDialog() {
    if (_imageList.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please insert image",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (_imageList.length < 2) {
      Fluttertoast.showToast(
          msg: "Please insert THREE images",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (selectBank == "Please select a Bank") {
      Fluttertoast.showToast(
          msg: "Please select a Bank",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Create Shop",
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Are you sure?",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text(
                    "Yes",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    insertShop();
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

  void _manageImageDialog(int num) {
    if (_imageList.length > num) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Manage shop images",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text(
                      "Update",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectImageDialog(num);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "Delete",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _imageList.removeAt(num);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    } else {
      _selectImageDialog(num);
    }
  }

  void _selectImageDialog(int num) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              "Select picture from:",
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    iconSize: 64,
                    onPressed: () => _onCamera(num),
                    icon: const Icon(Icons.camera_alt)),
                IconButton(
                    iconSize: 64,
                    onPressed: () => _onGallery(num),
                    icon: const Icon(Icons.photo)),
              ],
            ));
      },
    );
  }

  Future<void> _onCamera(int num) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage(num);
    } else {
      // print('No image selected.');
    }
  }

  Future<void> _onGallery(int num) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage(num);
    } else {
      // print('No image selected.');
    }
  }

  Future<void> cropImage(int num) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blueAccent,
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
      if (_imageList.length > num) {
        _imageList[num] = _image!;
      } else {
        _imageList.add(_image!);
      }
      setState(() {});
    }
  }

  void insertShop() {
    String sname = _snameEditingController.text;
    String sdesc = _sdescEditingController.text;
    String sbankacc = _sbankaccEditingController.text;
    String saddr = _saddrEditingController.text;
    List<String> base64Images = [];
    for (int i = 0; i < _imageList.length; i++) {
      base64Images.add(base64Encode(_imageList[i].readAsBytesSync()));
    }
    String images = json.encode(base64Images);

    http.post(Uri.parse("${ServerConfig.server}/php/insert_shop.php"), body: {
      "userid": widget.user.id,
      "sname": sname,
      "sdesc": sdesc,
      "sbank": selectBank.toString(),
      "sbankacc": sbankacc,
      "saddr": saddr,
      "image": images,
      "registershop": "registershop"
    }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Navigator.of(context).pop();

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (content) => SellerScreen(
                      user: widget.user,
                    )));
        return;
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        return;
      }
    });
  }
}
