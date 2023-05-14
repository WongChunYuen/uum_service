import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../models/order.dart';
import '../../models/shop.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';

class OrderHistoryDetailScreen extends StatefulWidget {
  final MyOrder order;
  const OrderHistoryDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderHistoryDetailScreen> createState() =>
      _OrderHistoryDetailScreenState();
}

class _OrderHistoryDetailScreenState extends State<OrderHistoryDetailScreen> {
  var seller, shop;

  @override
  void initState() {
    super.initState();
    loadSeller();
    loadShop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: Center(
        child: Container(
          height: 630,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Thank You for your order!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Divider(
                color: Colors.white,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text("Shop:",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.order.shopName.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("location:",
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      shop == null
                          ? const Text("-",
                              style: TextStyle(
                                color: Colors.white,
                              ))
                          : Text(shop.shopAddress.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                              )),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const Divider(
                color: Colors.white,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text("Seller:",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              const SizedBox(
                height: 12,
              ),
              seller == null
                  ? const Text(
                      '-',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          seller.name.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.chat), // whatsapp
                        //   onPressed: _openWhatsApp,
                        //   color: Colors.white,
                        // ),
                        GestureDetector(
                          onTap: _openWhatsApp,
                          child: ClipOval(
                            child: Image.asset(
                              "assets/whatsapp.png",
                              height: 40,
                              width: 40,
                            ),
                          ),
                        )
                      ],
                    ),
              const SizedBox(
                height: 12,
              ),
              const Divider(
                color: Colors.white,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text("Service:",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.order.serviceName.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("x ${widget.order.quantity}",
                          style: const TextStyle(
                            color: Colors.white,
                          )),
                      Text("RM ${widget.order.price}",
                          style: const TextStyle(
                            color: Colors.white,
                          )),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const Divider(
                color: Colors.white,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total amount:",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  Text("RM ${widget.order.totalAmount}",
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const Divider(
                color: Colors.white,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text("Details:",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              const SizedBox(
                height: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pick-up time:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.order.time.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Payment type:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.order.payment.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const Divider(
                color: Colors.white,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text("Remark:",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.order.remark.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loadSeller() {
    http.post(Uri.parse("${ServerConfig.server}/php/loadseller.php"),
        body: {"sellerid": widget.order.sellerId}).then((response) {
      print(response.body);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == "success") {
        setState(() {
          seller = User.fromJson(jsonResponse['data']);
        });
      }
    });
  }

  void loadShop() {
    http.post(Uri.parse("${ServerConfig.server}/php/loadshop.php"),
        body: {"shopid": widget.order.shopId}).then((response) {
      print(response.body);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == "success") {
        setState(() {
          shop = Shop.fromJson(jsonResponse['data']);
        });
      }
    });
  }

  Future<void> _openWhatsApp() async {
    var whatsapp = "+6${seller.phone}";
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
}
