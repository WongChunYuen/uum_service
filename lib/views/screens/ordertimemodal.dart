import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'quantityselector.dart';

class OrderTimeModal extends StatefulWidget {
  const OrderTimeModal({super.key, superkey});

  @override
  State<OrderTimeModal> createState() => _OrderTimeModalState();
}

class _OrderTimeModalState extends State<OrderTimeModal> {
  List<String> _options = ['Tng ewallet', 'COD'];
  List<String> _time = ['10-11', 'COD'];
  String _selectedOption = '', _selectedOptionA = '';
  bool areOptionsSelected = false;
  bool areOptionsSelectedA = false;
  late double screenHeight, screenWidth;
  final TextEditingController _remarkEditingController =
      TextEditingController();

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
          child: Container(
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
                                _selectedOptionA = option;
                                areOptionsSelectedA = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedOptionA == option
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
                                        color: _selectedOptionA == option
                                            ? Colors.green
                                            : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: _selectedOptionA == option
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
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value as String;
                          areOptionsSelected = true;
                        });
                      },
                    );
                  }).toList(),
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

  void _orderService() {}
}
