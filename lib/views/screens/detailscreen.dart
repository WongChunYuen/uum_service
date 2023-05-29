import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/shop.dart';
import '../../serverconfig.dart';
import '../../models/user.dart';
import 'shopservice.dart';

class DetailsScreen extends StatefulWidget {
  final Shop shop;
  final User user;
  const DetailsScreen({
    Key? key,
    required this.user,
    required this.shop,
  }) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TextEditingController _snameEditingController = TextEditingController();
  final TextEditingController _sdescEditingController = TextEditingController();
  final TextEditingController _saddrEditingController = TextEditingController();
  final TextEditingController _sopenController = TextEditingController();
  final TextEditingController _scloseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _image;
  final List<File> _imageList = [];
  var pathAsset = "assets/images/camera.png";
  bool _editKey = false;
  late double screenHeight, screenWidth, resWidth;
  TimeOfDay selectedOpenTime = TimeOfDay.now();
  TimeOfDay selectedCloseTime = TimeOfDay.now();

  late String openTime, closeTime;

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
        backgroundColor: Colors.grey[200],
        appBar: _editKey
            ? AppBar(title: const Text("Shop Details"))
            : AppBar(title: const Text("Shop Details"), actions: [
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
                            "Edit Shop Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const Text(
                            "Shop Details",
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
                          ? "Shop name must be longer than 3"
                          : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Shop Name',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          icon: Icon(
                            Icons.home,
                            color: Colors.blueGrey,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      enabled: _editKey,
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
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          icon: Icon(
                            Icons.description,
                            color: Colors.blueGrey,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      enabled: _editKey,
                      textInputAction: TextInputAction.next,
                      controller: _saddrEditingController,
                      validator: (val) =>
                          val!.isEmpty ? "Please enter shop address" : null,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Shop Address',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          icon: Icon(
                            Icons.place,
                            color: Colors.blueGrey,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () =>
                              _editKey ? _selectOpenTime(context) : null,
                          child: TextFormField(
                              enabled: false,
                              textInputAction: TextInputAction.next,
                              controller: _sopenController,
                              validator: (val) => val!.isEmpty
                                  ? "Please enter shop open time"
                                  : null,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: 'Open Time',
                                labelStyle: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                                icon: Icon(
                                  Icons.access_time,
                                  color: Colors.blueGrey,
                                ),
                              )),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("-"),
                      ),
                      Flexible(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () =>
                              _editKey ? _selectCloseTime(context) : null,
                          child: TextFormField(
                              enabled: false,
                              textInputAction: TextInputAction.next,
                              controller: _scloseController,
                              validator: (val) => val!.isEmpty
                                  ? "Please enter shop close time"
                                  : null,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: 'Close Time',
                                labelStyle: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
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
                                    _updateShopDialog(),
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
                        : Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.all(8),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                minWidth: screenWidth,
                                height: 50,
                                elevation: 10,
                                onPressed: _manageService,
                                color: Theme.of(context).colorScheme.primary,
                                child: const Text(
                                  "Manage Shop's Service",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                  ),
                ]),
              ),
            ),
          ]),
        ));
  }

  Future<void> _selectOpenTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedOpenTime,
    );

    if (pickedTime != null && pickedTime != selectedOpenTime) {
      setState(() {
        selectedOpenTime = pickedTime;
        openTime = _formatTime(selectedOpenTime);
        _sopenController.text = openTime;
      });
    }
  }

  Future<void> _selectCloseTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedCloseTime,
    );

    if (pickedTime != null && pickedTime != selectedCloseTime) {
      setState(() {
        selectedCloseTime = pickedTime;
        closeTime = _formatTime(selectedCloseTime);
        _scloseController.text = closeTime;
      });
    }
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final formatter = DateFormat.jm();
    return formatter.format(dateTime);
  }

  void _updateShopDialog() {
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
              "Update shop",
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
                      _updateShop();
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

  void _updateShop() {
    String sname = _snameEditingController.text;
    String sdesc = _sdescEditingController.text;
    String saddr = _saddrEditingController.text;
    String sopen = _sopenController.text;
    String sclose = _scloseController.text;
    List<String> base64Images = [];
    for (int i = 0; i < _imageList.length; i++) {
      base64Images.add(base64Encode(_imageList[i].readAsBytesSync()));
    }
    String images = json.encode(base64Images);

    http.post(Uri.parse("${ServerConfig.server}/php/update_shop.php"), body: {
      "shopid": widget.shop.shopId,
      "userid": widget.user.id,
      "sname": sname,
      "sdesc": sdesc,
      "saddr": saddr,
      "sopen": sopen,
      "sclose": sclose,
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
        setState(() {
          _editKey = false;
        });
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
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
            "Delete ${widget.shop.shopName}",
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
                    _deleteShop();
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

  void _deleteShop() {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/delete_shop.php"), body: {
        "shopid": widget.shop.shopId,
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
    _snameEditingController.text = widget.shop.shopName.toString();
    _sdescEditingController.text = widget.shop.shopDesc.toString();
    _saddrEditingController.text = widget.shop.shopAddress.toString();
    _sopenController.text = widget.shop.shopOpen.toString();
    _scloseController.text = widget.shop.shopClose.toString();
  }

  Future<void> _loadImages() async {
    _imageList.clear();
    int imageLength = int.parse(widget.shop.serviceImages.toString());

    for (int i = 1; i <= imageLength; i++) {
      String imageUrl =
          "${ServerConfig.server}/assets/serviceimages/${widget.shop.shopId}_$i.png";

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

  void _manageService() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => ShopServiceScreen(
                  shop: widget.shop,
                  userId: int.parse(widget.user.id.toString()),
                )));
  }
}
