import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/service.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';

class AdminDetailScreen extends StatefulWidget {
  final Service service;
  final User user;
  final User seller;
  const AdminDetailScreen(
      {Key? key,
      required this.user,
      required this.service,
      required this.seller})
      : super(key: key);

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  late double screenHeight, screenWidth, resWidth;
  final List<String> _imageList = [];
  final TextEditingController _sellernameController = TextEditingController();
  final TextEditingController _snameController = TextEditingController();
  final TextEditingController _sdescController = TextEditingController();
  final TextEditingController _spriceController = TextEditingController();
  final TextEditingController _saddrController = TextEditingController();
  final TextEditingController _sbankaccController = TextEditingController();

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
        appBar: AppBar(title: const Text("Details"), actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Delete"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
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
              child: SizedBox(
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
                              image: NetworkImage(_imageList[index]),
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
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.service.serviceName.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextFormField(
                      enabled: false,
                      controller: _sdescController,
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
                      enabled: false,
                      controller: _spriceController,
                      decoration: const InputDecoration(
                          labelText: 'Service Price/days',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.attach_money),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      enabled: false,
                      controller: _saddrController,
                      decoration: const InputDecoration(
                          labelText: 'Service Address',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.place),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      enabled: false,
                      controller: _sellernameController,
                      decoration: const InputDecoration(
                          labelText: 'Owner Name',
                          labelStyle: TextStyle(),
                          icon: Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                ]),
              ),
            )
          ]),
        ));
  }

  Future<void> _loadDetails() async {
    _sellernameController.text = widget.seller.name.toString();
    _snameController.text = widget.service.serviceName.toString();
    _sdescController.text = widget.service.serviceDesc.toString();
    _spriceController.text = widget.service.servicePrice.toString();
    _saddrController.text = widget.service.serviceAddress.toString();
    _sbankaccController.text = widget.service.serviceBankAcc.toString();
  }

  Future<void> _loadImages() async {
    int imageLength = int.parse(widget.service.serviceImages.toString());

    for (int i = 1; i <= imageLength; i++) {
      String imageUrl =
          "${ServerConfig.server}/assets/serviceimages/${widget.service.serviceId}_$i.png";

      _imageList.add(imageUrl);
    }
    setState(() {});
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
}
