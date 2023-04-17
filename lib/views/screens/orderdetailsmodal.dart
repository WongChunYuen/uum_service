import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:uum_service/views/screens/orderdetailsmodal.dart';

import 'ordertimemodal.dart';
import 'quantityselector.dart';

class OrderDetailsModal extends StatefulWidget {
  const OrderDetailsModal({super.key, superkey});

  @override
  State<OrderDetailsModal> createState() => _OrderDetailsModalState();
}

class _OrderDetailsModalState extends State<OrderDetailsModal> {
  List<String> _options = ['Option A', 'Option B', 'option C'];
  List<String> _optionsA = ['Option AA', 'Option AB', 'option AC', 'win'];
  String _selectedOption = '', _selectedOptionA = '';
  bool areOptionsSelected = false;
  bool areOptionsSelectedA = false;
  late double screenHeight, screenWidth;

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
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16,),
                const Text(
                  'Select an option',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _options.map((option) {
                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOption = option;
                                areOptionsSelected = true;
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
                  'Select a new optionA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _optionsA.map((option) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity'),
                    QuantitySelector(
                      initialValue: 1,
                      onValueChanged: (value) {
                        // Handle the new value here
                      },
                    ),
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
                    if (areOptionsSelected && areOptionsSelectedA) {
                      // Perform the purchase
                      _orderService();
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

  void _orderService() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const OrderTimeModal();
      },
    );
  }
}
