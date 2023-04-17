import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../models/service.dart';
import '../../serverconfig.dart';
import '../../models/user.dart';

class DetailsScreen extends StatefulWidget {
  final Service service;
  final User user;
  const DetailsScreen({
    Key? key,
    required this.user,
    required this.service,
  }) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TextEditingController _snameEditingController = TextEditingController();
  final TextEditingController _sdescEditingController = TextEditingController();
  final TextEditingController _spriceEditingController =
      TextEditingController();
  final TextEditingController _saddrEditingController = TextEditingController();
  final TextEditingController _sbankaccEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _image;
  final List<File> _imageList = [];
  var pathAsset = "assets/images/camera.png";
  bool _editKey = false;
  late double screenHeight, screenWidth, resWidth;
  String selectBank = "";
  List<String> bankList = [
    "Please select a Bank",
    "Bank 1",
    "Bank 2",
    "Bank 3",
    "MayBank",
  ];

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
    } else {
      resWidth = screenWidth * 0.90;
    }
    return Scaffold(
        appBar: AppBar(title: const Text("Service Details"), actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Edit"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Delete"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              _editKey = true;
              setState(() {});
            } else if (value == 1) {
              _deletesDialog();
            }
          }),
        ]),
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 16,
            ),
            Center(
              child: _editKey
                  ? SizedBox(
                      height: 250,
                      child: PageView.builder(
                          itemCount: _imageList.length + 1,
                          controller: PageController(viewportFraction: 0.9),
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
                    )
                  : SizedBox(
                      height: 250,
                      child: PageView.builder(
                          itemCount: _imageList.length,
                          controller: PageController(viewportFraction: 0.9),
                          itemBuilder: (BuildContext context, int index) {
                            return Transform.scale(
                              scale: 1,
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: FileImage(_imageList[index]),
                                    fit: BoxFit.cover,
                                  )),
                                ),
                              ),
                            );
                          }),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _editKey
                        ? const Text(
                            "Edit Service Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const Text(
                            "Service Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  TextFormField(
                      enabled: _editKey,
                      textInputAction: TextInputAction.next,
                      controller: _snameEditingController,
                      validator: (val) => val!.isEmpty || (val.length < 4)
                          ? "Service name must be longer than 3"
                          : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Service Name',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.home),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      enabled: _editKey,
                      textInputAction: TextInputAction.next,
                      controller: _sdescEditingController,
                      validator: (val) => val!.isEmpty || (val.length < 10)
                          ? "Service description must be longer than 10"
                          : null,
                      maxLines: 4,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Service Description',
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.description,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      enabled: _editKey,
                      textInputAction: TextInputAction.next,
                      controller: _spriceEditingController,
                      validator: (val) =>
                          val!.isEmpty ? "Please enter service price" : null,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Service Price/days',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.attach_money),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  _editKey
                      ? DropdownButtonFormField(
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
                        )
                      : DropdownButtonFormField(
                          value: selectBank,
                          decoration: const InputDecoration(
                              labelText: 'Bank',
                              icon: Icon(Icons.add_card),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0),
                              )),
                          onChanged: null,
                          items: bankList.map((selectBank) {
                            return DropdownMenuItem(
                                value: selectBank,
                                child: Text(
                                  selectBank,
                                ));
                          }).toList(),
                        ),
                  TextFormField(
                      enabled: _editKey,
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
                      enabled: _editKey,
                      textInputAction: TextInputAction.next,
                      controller: _saddrEditingController,
                      validator: (val) =>
                          val!.isEmpty ? "Please enter service address" : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Service Address',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.place),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    child: _editKey
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 130,
                                height: 50,
                                child: ElevatedButton(
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  onPressed: () => {
                                    _updateServiceDialog(),
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                height: 50,
                                child: ElevatedButton(
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  onPressed: () {
                                    _editKey = false;
                                    setState(() {
                                      _loadImages();
                                      _loadDetails();
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ]),
              ),
            )
          ]),
        ));
  }

  void _updateServiceDialog() {
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Update service",
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
                      _updateService();
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
              "Manage service images",
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

  void _updateService() {
    if (selectBank == "Please select a Bank") {
      Fluttertoast.showToast(
          msg: "Please select a Bank",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    String sname = _snameEditingController.text;
    String sdesc = _sdescEditingController.text;
    String sprice = _spriceEditingController.text;
    String saddr = _saddrEditingController.text;
    String sbank = selectBank;
    String sbankacc = _sbankaccEditingController.text;
    List<String> base64Images = [];
    for (int i = 0; i < _imageList.length; i++) {
      base64Images.add(base64Encode(_imageList[i].readAsBytesSync()));
    }
    String images = json.encode(base64Images);

    http.post(Uri.parse("${ServerConfig.server}/php/update_service.php"),
        body: {
          "serviceid": widget.service.serviceId,
          "userid": widget.user.id,
          "sname": sname,
          "sdesc": sdesc,
          "sprice": sprice,
          "saddr": saddr,
          "sbank": sbank,
          "sbankacc": sbankacc,
          "image": images,
        }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        _editKey = false;
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
        setState(() {selectBank = sbank;});
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

  void _deletesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            "Delete ${widget.service.serviceName}",
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
                    _deleteService();
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

  void _deleteService() {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/delete_service.php"),
          body: {
            "serviceid": widget.service.serviceId,
          }).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "Success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          Navigator.pop(context);
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
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _loadDetails() async {
    _snameEditingController.text = widget.service.serviceName.toString();
    _sdescEditingController.text = widget.service.serviceDesc.toString();
    _spriceEditingController.text = widget.service.servicePrice.toString();
    _saddrEditingController.text = widget.service.serviceAddress.toString();
    _sbankaccEditingController.text = widget.service.serviceBankAcc.toString();
    selectBank = widget.service.serviceBank.toString();
  }

  Future<void> _loadImages() async {
    _imageList.clear();
    int imageLength = int.parse(widget.service.serviceImages.toString());

    for (int i = 1; i <= imageLength; i++) {
      String imageUrl =
          "${ServerConfig.server}/assets/serviceimages/${widget.service.serviceId}_$i.png";

      File file = await urlToFile(imageUrl);
      _imageList.add(file);
    }
    setState(() {});
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath${rng.nextInt(1000)}.png');
    var uri = Uri.parse(imageUrl);
    http.Response response = await http.get(uri);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
