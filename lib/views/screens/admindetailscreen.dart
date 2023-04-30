import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/shop.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'shopservice.dart';

class AdminDetailScreen extends StatefulWidget {
  final Shop shop;
  // final Service service;
  final User user;
  final User seller;
  const AdminDetailScreen(
      {Key? key, required this.user, required this.shop, required this.seller})
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
                      widget.shop.shopName.toString(),
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
                          labelText: 'Service Price Range',
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
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
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
                        onPressed: _showService,
                        color: Theme.of(context).colorScheme.primary,
                        child: const Text(
                          "Show Shop's Service",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            )
          ]),
        ));
  }

  Future<void> _loadDetails() async {
    _sellernameController.text = widget.seller.name.toString();
    _snameController.text = widget.shop.shopName.toString();
    _sdescController.text = widget.shop.shopDesc.toString();
    _spriceController.text = "10 - 15"; // need to change
    _saddrController.text = widget.shop.shopAddress.toString();
    _sbankaccController.text = widget.shop.shopBankAcc.toString();
  }

  Future<void> _loadImages() async {
    int imageLength = int.parse(widget.shop.serviceImages.toString());

    for (int i = 1; i <= imageLength; i++) {
      String imageUrl =
          "${ServerConfig.server}/assets/serviceimages/${widget.shop.shopId}_$i.png";

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

  void _showService() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => ShopServiceScreen(
                  shop: widget.shop,
                  userId: int.parse(widget.user.id.toString()),
                )));
  }
}
