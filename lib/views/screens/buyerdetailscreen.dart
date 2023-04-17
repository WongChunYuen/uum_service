import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/service.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'dart:async';
import 'dart:io';

import 'orderdetailsmodal.dart';

class BuyerDetailScreen extends StatefulWidget {
  final Service service;
  final User user;
  final User seller;
  const BuyerDetailScreen(
      {Key? key,
      required this.user,
      required this.service,
      required this.seller})
      : super(key: key);

  @override
  State<BuyerDetailScreen> createState() => _BuyerDetailScreenState();
}

class _BuyerDetailScreenState extends State<BuyerDetailScreen> {
  late double screenHeight, screenWidth, resWidth;
  final List<String> _imageList = [];
  final TextEditingController _sellernameController = TextEditingController();
  final TextEditingController _snameController = TextEditingController();
  final TextEditingController _sdescController = TextEditingController();
  final TextEditingController _spriceController = TextEditingController();
  final TextEditingController _saddrController = TextEditingController();
  final TextEditingController _sbankaccController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCheckboxChecked = false;

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
        IconButton(
          icon: const Icon(Icons.whatsapp),
          onPressed: _openWhatsApp,
        ),
        PopupMenuButton(itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("Report"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("Nothing"),
            ),
          ];
        }, onSelected: (value) {
          if (value == 0) {
            // report
          }
        }),
      ]),
      body: Column(
        children: [
          SingleChildScrollView(
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
          ),
          _orderButton(),
        ],
      ),
    );
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

  Future<void> _openWhatsApp() async {
    var whatsapp = "+6${widget.seller.phone}";
    var whatsappURlAndroid =
        "whatsapp://send?phone=$whatsapp&text=Hello, I have something to ask.";
    var whatappURLIos = "https://wa.me/$whatsapp";
    // launch(whatsappURlAndroid);

    if (Platform.isIOS) {
      // for iOS phone only
      if (await launch(whatappURLIos)) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp not installed")));
      }
    } else {
      // android , web
      if (await launch(whatsappURlAndroid)) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp not installed")));
      }
    }
  }

  Widget _orderButton() {
    if (widget.user.id.toString() == "0" &&
        widget.user.email.toString() == "unregistered") {
      return const Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Card(
              child: Text("Please login an account to get more information")),
        ),
      );
    } else {
      return Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Card(
            child: SizedBox(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(16),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minWidth: screenWidth,
                  height: 50,
                  elevation: 10,
                  onPressed: _orderDetails,
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text(
                    'Order',
                    style: TextStyle(color: Colors.white, fontSize: 23),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _orderDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const OrderDetailsModal();
      },
    );
  }
}
