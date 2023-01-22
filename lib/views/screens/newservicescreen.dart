import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import '../../serverconfig.dart';

class NewServiceScreen extends StatefulWidget {
  final User user;
  final Position position;
  final List<Placemark> placemarks;
  const NewServiceScreen(
      {super.key,
      required this.user,
      required this.position,
      required this.placemarks});

  @override
  State<NewServiceScreen> createState() => _NewServiceScreenState();
}

class _NewServiceScreenState extends State<NewServiceScreen> {
  final TextEditingController _snameEditingController = TextEditingController();
  final TextEditingController _sdescEditingController = TextEditingController();
  final TextEditingController _spriceEditingController =
      TextEditingController();
  final TextEditingController _saddrEditingController = TextEditingController();
  final TextEditingController _sbankaccEditingController =
      TextEditingController();
  final TextEditingController _sstateEditingController =
      TextEditingController();
  final TextEditingController _slocalEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _lat, _lng;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _lat = widget.position.latitude.toString();
    _lng = widget.position.longitude.toString();
    _sstateEditingController.text =
        widget.placemarks[0].administrativeArea.toString();
    _slocalEditingController.text = widget.placemarks[0].locality.toString();
  }

  File? _image;
  final List<File> _imageList = [];
  var pathAsset = "assets/images/camera.png";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("New Service")),
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 16,
            ),
            Center(
              child: SizedBox(
                height: 200,
                child: PageView.builder(
                    itemCount: 3,
                    controller: PageController(viewportFraction: 0.7),
                    onPageChanged: (int index) =>
                        setState(() => _index = index),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return PageOne();
                      } else if (index == 1) {
                        return PageTwo();
                      } else {
                        return PageThree();
                      }
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
                      "Create New Servcie",
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
                          val!.isEmpty ? "Please enter service address" : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Service Address',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.place),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  Row(
                    children: [
                      Flexible(
                          flex: 5,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  val!.isEmpty || (val.length < 3)
                                      ? "State"
                                      : null,
                              enabled: false,
                              controller: _sstateEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  labelText: 'States',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.flag),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  )))),
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: false,
                            validator: (val) => val!.isEmpty || (val.length < 3)
                                ? "Locality"
                                : null,
                            controller: _slocalEditingController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Locality',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.map),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      child: const Text(
                        'Create Service',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () => {
                        _newServiceDialog(),
                      },
                    ),
                  ),
                ]),
              ),
            )
          ]),
        ));
  }

  void _newServiceDialog() {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Create service",
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
                    insertService();
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

  void _selectImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select picture from:",
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    iconSize: 64,
                    onPressed: _onCamera,
                    icon: const Icon(Icons.camera_alt)),
                IconButton(
                    iconSize: 64,
                    onPressed: _onGallery,
                    icon: const Icon(Icons.photo)),
              ],
            ));
      },
    );
  }

  Future<void> _onCamera() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      // print('No image selected.');
    }
  }

  Future<void> _onGallery() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      // print('No image selected.');
    }
  }

  Future<void> cropImage() async {
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
      _imageList.add(_image!);
      setState(() {});
    }
  }

  void insertService() {
    String sname = _snameEditingController.text;
    String sdesc = _sdescEditingController.text;
    String sprice = _spriceEditingController.text;
    String sbankacc = _sbankaccEditingController.text;
    String saddr = _saddrEditingController.text;
    String state = _sstateEditingController.text;
    String local = _slocalEditingController.text;
    String base64Image1 = base64Encode(_imageList[0].readAsBytesSync());
    String base64Image2 = base64Encode(_imageList[1].readAsBytesSync());
    String base64Image3 = base64Encode(_imageList[2].readAsBytesSync());

    http.post(Uri.parse("${ServerConfig.server}/php/insert_service.php"),
        body: {
          "userid": widget.user.id,
          "sname": sname,
          "sdesc": sdesc,
          "sprice": sprice,
          "sbankacc": sbankacc,
          "saddr": saddr,
          "state": state,
          "local": local,
          "lat": _lat,
          "lon": _lng,
          "image1": base64Image1,
          "image2": base64Image2,
          "image3": base64Image3,
          "registerservice": "registerservice"
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

  Widget PageOne() {
    return Transform.scale(
      scale: 1,
      child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: GestureDetector(
            onTap: _selectImageDialog,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: _imageList.length > 0
                    ? FileImage(_imageList[0]) as ImageProvider
                    : AssetImage(pathAsset),
                fit: BoxFit.cover,
              )),
            ),
          )),
    );
  }

  Widget PageTwo() {
    return Transform.scale(
      scale: 1,
      child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: GestureDetector(
            onTap: _selectImageDialog,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: _imageList.length > 1
                    ? FileImage(_imageList[1]) as ImageProvider
                    : AssetImage(pathAsset),
                fit: BoxFit.cover,
              )),
            ),
          )),
    );
  }

  Widget PageThree() {
    return Transform.scale(
      scale: 1,
      child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: GestureDetector(
            onTap: _selectImageDialog,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: _imageList.length > 2
                    ? FileImage(_imageList[2]) as ImageProvider
                    : AssetImage(pathAsset),
                fit: BoxFit.cover,
              )),
            ),
          )),
    );
  }
}
