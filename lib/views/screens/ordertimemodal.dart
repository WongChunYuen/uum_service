import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/service.dart';
import '../../models/user.dart';

class OrderTimeModal extends StatefulWidget {
  final int quantity;
  final Service service;
  final User user;
  final User seller;
  final String shopId;
  final String shopName;
  const OrderTimeModal(
      {super.key,
      superkey,
      required this.quantity,
      required this.user,
      required this.seller,
      required this.service,
      required this.shopName,
      required this.shopId});

  @override
  State<OrderTimeModal> createState() => _OrderTimeModalState();
}

class _OrderTimeModalState extends State<OrderTimeModal> {
  final List<String> _options = ['Tng ewallet', 'COD'];
  final List<String> _time = [
    'now',
    'after 10 mins',
    'after 20 mins',
    'after 30 mins'
  ];
  String _selectedPayment = '', _selectedTime = '';
  bool areOptionsSelected = false;
  bool areOptionsSelectedA = false;
  late double screenHeight, screenWidth, totalAmount;
  final TextEditingController _remarkEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    totalAmount =
        double.parse(widget.service.servicePrice.toString()) * widget.quantity;
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
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Time to pick-up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _time.map((option) {
                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTime = option;
                                areOptionsSelectedA = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedTime == option
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
                                        color: _selectedTime == option
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: _selectedTime == option
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
                  'Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  children: _options.map((option) {
                    return RadioListTile(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedPayment,
                      onChanged: (value) {
                        setState(() {
                          _selectedPayment = value as String;
                          areOptionsSelected = true;
                        });
                      },
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Amount: RM ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Remark',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _remarkEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ))),
                const SizedBox(height: 8),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minWidth: screenWidth,
                  height: 50,
                  elevation: 10,
                  onPressed: () {
                    if (areOptionsSelected && areOptionsSelectedA) {
                      // Perform the purchase
                      _orderService();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please complete the option",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          fontSize: 14.0);
                    }
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text(
                    'Order Now',
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

  Future _orderService() async {
    String remark;
    if (_remarkEditingController.text.isEmpty) {
      remark = '-';
    } else {
      remark = _remarkEditingController.text;
    }
    final order = FirebaseFirestore.instance.collection('orders');

    final orderData = {
      'userId': widget.user.id,
      'sellerId': widget.seller.id,
      'shopId': widget.shopId,
      'shopName': widget.shopName,
      'serviceName': widget.service.serviceName,
      'quantity': widget.quantity.toString(),
      'price': widget.service.servicePrice,
      'totalAmount': totalAmount.toStringAsFixed(2),
      'time': _selectedTime,
      'payment': _selectedPayment,
      'remark': remark
    };

    await order.add(orderData);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "Order successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 14.0);
    return;
  }
}
