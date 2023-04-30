import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/service.dart';
import '../../models/shop.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'ordertimemodal.dart';
import 'quantityselector.dart';
import 'package:http/http.dart' as http;

class OrderDetailsModal extends StatefulWidget {
  final Shop shop;
  final User user;
  final User seller;
  const OrderDetailsModal(
      {Key? key, required this.shop, required this.user, required this.seller})
      : super(key: key);

  @override
  State<OrderDetailsModal> createState() => _OrderDetailsModalState();
}

class _OrderDetailsModalState extends State<OrderDetailsModal> {
  List<Service> serviceList = <Service>[];
  List<String> _serviceName = [];
  List<String> _servicePrice = [];
  int index = -1;
  int quantity = 1;
  String _selectedOption = '', serviceTitle = '';
  bool areOptionsSelected = false;
  bool areOptionsSelectedA = false;
  late double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                serviceTitle == 'No'
                    ? const Text(
                        'No services yet',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _serviceName.map((option) {
                            return Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedOption = option;
                                      areOptionsSelected = true;
                                      index =
                                          _serviceName.indexOf(_selectedOption);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedOption == option
                                            ? Colors.green
                                            : Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(option),
                                        const SizedBox(width: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _selectedOption == option
                                                  ? Colors.green
                                                  : Colors.transparent,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: _selectedOption == option
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.green,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 8),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _selectedOption == ''
                    ? const Text(
                        'RM -',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      )
                    : serviceList[index].serviceStatus == 'unavailable'
                        ? const Text(
                            'The service is not available now',
                            style: TextStyle(fontSize: 24, color: Colors.red),
                          )
                        : Text(
                            'RM ${_servicePrice[index]}',
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                const SizedBox(height: 8),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity'),
                    QuantitySelector(
                        initialValue: 1, onValueChanged: handleQuantityChanged),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minWidth: screenWidth,
                  height: 50,
                  elevation: 10,
                  onPressed: () {
                    if (areOptionsSelected
                        // && areOptionsSelectedA
                        ) {
                      if (serviceList[index].serviceStatus == 'unavailable') {
                        Fluttertoast.showToast(
                            msg: "The service is not available now",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            fontSize: 14.0);
                      } else {
                        _orderService();
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please select the service",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          fontSize: 14.0);
                    }
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontSize: 23),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadServices() {
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/load_service.php?shopid=${widget.shop.shopId}"),
    )
        .then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          var extractdata = jsondata['data'];
          if (extractdata['services'] != null) {
            serviceList = <Service>[];
            extractdata['services'].forEach((v) {
              serviceList.add(Service.fromJson(v));
            });
            serviceTitle = "Found";
            serviceArray();
          } else {
            serviceTitle = "No";
            serviceList.clear();
          }
        } else {
          serviceTitle = "No";
          serviceList.clear();
        }
      }
      setState(() {});
    });
  }

  void serviceArray() {
    for (int i = 0; i < serviceList.length; i++) {
      _serviceName.add(serviceList[i].serviceName.toString());
      _servicePrice.add(serviceList[i].servicePrice.toString());
    }
  }

  void handleQuantityChanged(int value) {
    quantity = value;
  }

  void _orderService() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return OrderTimeModal(
          quantity: quantity,
          service: serviceList[index],
          user: widget.user,
          seller: widget.seller,
          shopName: widget.shop.shopName.toString(),
          shopId: widget.shop.shopId.toString(),
        );
      },
    );
  }
}
