import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import '../../models/service.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'newservicescreen.dart';

class SellerScreen extends StatefulWidget {
  final User user;
  const SellerScreen({super.key, required this.user});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  var _lat, _lng;
  late Position _position;
  List<Service> serviceList = <Service>[];
  String titlecenter = "Loading...";
  var placemarks;

  late double screenHeight, screenWidth, resWidth;
  int rowcount = 2;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    serviceList = [];
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
      appBar: AppBar(title: const Text("My Service"), actions: [
        PopupMenuButton(itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("New Service"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("Order List"),
            ),
          ];
        }, onSelected: (value) {
          if (value == 0) {
            _gotoNewService();
          } else if (value == 1) {
            // Show order list
          }
        }),
      ]),
      body: serviceList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Your current service (${serviceList.length} found)",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: rowcount,
                    children: List.generate(serviceList.length, (index) {
                      return Card(
                        elevation: 8,
                        child: InkWell(
                          onTap: () {
                            // show details of the service
                          },
                          onLongPress: () {
                            // delete the service
                          },
                          child: Column(children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Flexible(
                              flex: 6,
                              child: CachedNetworkImage(
                                width: resWidth / 2,
                                fit: BoxFit.cover,
                                imageUrl:
                                    "${ServerConfig.server}/assets/serviceimages/${serviceList[index].serviceId}_1.png",
                                placeholder: (context, url) =>
                                    const LinearProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            Flexible(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        truncateString(
                                            serviceList[index]
                                                .serviceName
                                                .toString(),
                                            15),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          "RM ${double.parse(serviceList[index].servicePrice.toString()).toStringAsFixed(2)}"),
                                      Text(serviceList[index]
                                          .serviceDate
                                          .toString()),
                                    ],
                                  ),
                                ))
                          ]),
                        ),
                      );
                    }),
                  ),
                )
              ],
            ),
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

  Future<void> _gotoNewService() async {
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 10,
      message: const Text("Searching your current location"),
      title: null,
    );
    progressDialog.show();
    if (await _checkPermissionGetLoc()) {
      progressDialog.dismiss();
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => NewServiceScreen(
                  position: _position,
                  user: widget.user,
                  placemarks: placemarks)));
      _loadServices();
    } else {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      progressDialog.dismiss();
    }
  }

//check permission,get location,get address return false if any problem.
  Future<bool> _checkPermissionGetLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please allow the app to access the location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Geolocator.openLocationSettings();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      Geolocator.openLocationSettings();
      return false;
    }
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    try {
      placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);
    } catch (e) {
      Fluttertoast.showToast(
          msg:
              "Error in fixing your location. Make sure internet connection is available and try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return false;
    }
    return true;
  }

  void _loadServices() {
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/load_service.php?userid=${widget.user.id}"),
    )
        .then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response
            .body); //decode response body that retrieved to jsondata array
        if (jsondata['status'] == 'success') {
          var extractdata = jsondata['data']; //extract data from jsondata array
          if (extractdata['services'] != null) {
            serviceList = <Service>[];
            extractdata['services'].forEach((v) {
              //traverse services array list and add to the list object array serviceList
              serviceList.add(Service.fromJson(
                  v)); //add each product array to the list object array serviceList
            });
            titlecenter = "Found";
          } else {
            titlecenter =
                "No Service Available"; //if no data returned show title center
            serviceList.clear();
          }
        } else {
          titlecenter = "No Service Available";
        }
      } else {
        titlecenter = "No Service Available"; //status code other than 200
        serviceList.clear(); //clear serviceList array
      }
      setState(() {});
    });
  }
}
