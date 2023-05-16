import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../models/service.dart';
import '../../models/shop.dart';
import '../../serverconfig.dart';
import 'serviceeditdialog.dart';

class ShopServiceScreen extends StatefulWidget {
  final Shop shop;
  final int userId;
  const ShopServiceScreen(
      {super.key, required this.shop, required this.userId});

  @override
  State<ShopServiceScreen> createState() => _ShopServiceScreenState();
}

class _ShopServiceScreenState extends State<ShopServiceScreen> {
  List<Service> serviceList = <Service>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  int rowcount = 2;
  final TextEditingController _createsnameEditingController =
      TextEditingController();
  final TextEditingController _createspriceEditingController =
      TextEditingController();

  Future refresh() async {
    _loadServices();
  }

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      rowcount = 3;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop's Services"),
      ),
      body: serviceList.isEmpty
          ? Center(
              child: RefreshIndicator(
              onRefresh: refresh,
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: refresh, child: myStatefulWidget())),
              ],
            ),
      floatingActionButton: widget.userId > 10
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  onPressed: () {
                    _createNewServiceDialog();
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget myStatefulWidget() {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: serviceList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (widget.userId > 10) {
              _showEditDialog(index);
            }
            _loadServices();
          },
          child: customListItemTwo(
              title: serviceList[index].serviceName.toString(),
              price: serviceList[index].servicePrice.toString(),
              subtitle: serviceList[index].serviceStatus.toString(),
              index: index),
        );
      },
    );
  }

  Widget customListItemTwo({
    required String title,
    required String price,
    required String subtitle,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Container(
        decoration: BoxDecoration(
          color: serviceList[index].serviceStatus == 'available'
              ? Colors.white
              : Colors.black12,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 11.0, 2.0, 0.0),
                  child: _articleDescription(
                    title: title,
                    price: price,
                    subtitle: subtitle,
                  ),
                ),
              ),
              PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 0) {
                    _deleteDialog(index);
                  }
                },
                child: const Icon(
                  Icons.more_vert,
                  size: 25.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _articleDescription({
    required String title,
    required String price,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: .0)),
              const SizedBox(height: 8),
              Text(
                "RM $price",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.black54,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: .0)),
              const SizedBox(height: 8),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void _createNewServiceDialog() async {
    showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create Service"),
          content: SizedBox(
            width: 300.0,
            height: 125.0,
            child: Column(
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _createsnameEditingController,
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
                  controller: _createspriceEditingController,
                  validator: (val) =>
                      val!.isEmpty ? "Please enter service price" : null,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Service Price',
                    icon: Icon(Icons.attach_money),
                  ),
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
                    "Create",
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    String createsname = _createsnameEditingController.text;
                    String createsprice = _createspriceEditingController.text;
                    _createNewService(createsname, createsprice);
                    _loadServices();
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
      },
    );
  }

  void _createNewService(String sName, String sPrice) {
    http.post(Uri.parse("${ServerConfig.server}/php/insert_service.php"),
        body: {
          "shopid": widget.shop.shopId,
          "sname": sName,
          "sprice": sPrice,
          "registerservice": "registerservice"
        }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        _createsnameEditingController.clear();
        _createspriceEditingController.clear();
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

  void _loadServices() {
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/load_service.php?shopid=${widget.shop.shopId}"),
    )
        .then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          var extractdata = jsondata['data'];
          if (extractdata['services'] != null) {
            serviceList = <Service>[];
            extractdata['services'].forEach((v) {
              serviceList.add(Service.fromJson(v));
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No Service Available";
            serviceList.clear();
          }
        } else {
          titlecenter = "No Service Available";
          serviceList.clear();
        }
      }
      setState(() {});
    });
  }

  void _showEditDialog(int index) {
    showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ServiceEditDialog(
            shopId: widget.shop.shopId.toString(), service: serviceList[index]);
      },
    );
    setState(() {
      _loadServices();
    });
  }

  void _deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            "Delete ${truncateString(serviceList[index].serviceName.toString(), 15)}",
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
                    _deleteService(index);
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

  void _deleteService(index) {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/delete_service.php"),
          body: {
            "serviceid": serviceList[index].serviceId,
          }).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "Success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          _loadServices();
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
