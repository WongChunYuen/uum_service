import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../models/service.dart';
import '../../serverconfig.dart';

class ServiceEditDialog extends StatefulWidget {
  final String shopId;
  final Service service;

  const ServiceEditDialog(
      {Key? key, required this.shopId, required this.service})
      : super(key: key);

  @override
  State<ServiceEditDialog> createState() => _ServiceEditDialogState();
}

class _ServiceEditDialogState extends State<ServiceEditDialog> {
  bool _isEnabled = false;
  final TextEditingController _snameEditingController = TextEditingController();
  final TextEditingController _spriceEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _snameEditingController.text = widget.service.serviceName.toString();
    _spriceEditingController.text = widget.service.servicePrice.toString();
    if (widget.service.serviceStatus == 'available') {
      _isEnabled = true;
    } else {
      _isEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit service name"),
      content: SizedBox(
        width: 300.0,
        height: 180.0,
        child: Column(
          children: [
            TextFormField(
              textInputAction: TextInputAction.next,
              controller: _snameEditingController,
              validator: (val) =>
                  val!.isEmpty ? "Please enter service name" : null,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                icon: Icon(Icons.feed),
              ),
            ),
            TextFormField(
              textInputAction: TextInputAction.done,
              controller: _spriceEditingController,
              validator: (val) =>
                  val!.isEmpty ? "Please enter service price" : null,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Service Price',
                icon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text('Avalability',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEnabled = !_isEnabled;
                    });
                  },
                  child: Container(
                    width: 50.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: _isEnabled ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: _isEnabled
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 20.0,
                          height: 20.0,
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              child: const Text(
                "Save",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                String id = widget.service.serviceId.toString();
                String newname = _snameEditingController.text;
                String newprice = _spriceEditingController.text;
                _updateService(id, newname, newprice);
              },
            ),
            TextButton(
              child: const Text(
                "Cancel",
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
  }

  void _updateService(String id, String newname, String newprice) {
    String status = "";
    if (_isEnabled) {
      status = "available";
    } else {
      status = "unavailable";
    }
    http.post(Uri.parse("${ServerConfig.server}/php/update_service.php"),
        body: {
          "shopid": widget.shopId,
          "serviceid": id,
          "sname": newname,
          "sprice": newprice,
          "sstatus": status,
        }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
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
}
