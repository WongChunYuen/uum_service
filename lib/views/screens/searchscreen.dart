import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import '../../models/service.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'admindetailscreen.dart';
import 'buyerdetailscreen.dart';

class SearchScreen extends StatefulWidget {
  final User user;
  const SearchScreen({super.key, required this.user});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Service> serviceList = <Service>[];
  String titlecenter = "Search something";
  late double screenHeight, screenWidth, resWidth;
  TextEditingController searchController = TextEditingController();
  String search = "all";
  var seller;
  var color;
  var numofpage, curpage = 1;
  int numberofresult = 0;
  int limit = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          color: Colors.white.withOpacity(0.7),
          child: TextField(
            autofocus: true,
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search",
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  search = searchController.text;
                  if (search != "") {
                    _loadServices(search, 1);
                  }
                },
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              search = searchController.text;
              if (search != "") {
                _loadServices(search, 1);
              }
            },
          ),
        ),
      ),
      body: serviceList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : search == 'all'
              ? const Center(
                  child: Text("Search something",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Services ($numberofresult found)",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: MyStatefulWidget()),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: numofpage,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if ((curpage - 1) == index) {
                            color = Colors.indigoAccent;
                          } else {
                            color = Colors.black;
                          }
                          return TextButton(
                              onPressed: () =>
                                  {_loadServices(search, index + 1)},
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(color: color, fontSize: 18),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget MyStatefulWidget() {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: serviceList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            _showDetails(index);
          },
          child: CustomListItemTwo(
              thumbnail: CachedNetworkImage(
                imageUrl:
                    "${ServerConfig.server}/assets/serviceimages/${serviceList[index].serviceId}_1.png",
                placeholder: (context, url) => const LinearProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: serviceList[index].serviceName.toString(),
              subtitle: serviceList[index].serviceDesc.toString(),
              price:
                  "RM ${double.parse(serviceList[index].servicePrice.toString()).toStringAsFixed(2)}",
              index: index),
        );
      },
    );
  }

  Widget CustomListItemTwo({
    required Widget thumbnail,
    required String title,
    required String subtitle,
    required String price,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: thumbnail,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: _ArticleDescription(
                  title: title,
                  subtitle: subtitle,
                  price: price,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ArticleDescription({
    required String title,
    required String subtitle,
    required String price,
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
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: .0)),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 17.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _loadServices(String search, int pageNo) {
    curpage = pageNo;
    numofpage ?? 1;
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/loadallservices.php?search=$search&pageno=$pageNo&limit=$limit"),
    )
        .then((response) {
      ProgressDialog progressDialog = ProgressDialog(
        context,
        blur: 5,
        message: const Text("Loading..."),
        title: null,
      );
      progressDialog.show();
      print(response.body);
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          var extractdata = jsondata['data'];

          if (extractdata['services'] != null) {
            numofpage = int.parse(jsondata['numofpage']);
            numberofresult = int.parse(jsondata['numberofresult']);

            serviceList = <Service>[];
            extractdata['services'].forEach((v) {
              serviceList.add(Service.fromJson(v));
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No service Available";
            serviceList.clear();
          }
        } else {
          titlecenter = "No service Available";
          serviceList.clear();
        }
      } else {
        titlecenter = "No service Available";
        serviceList.clear();
      }
      setState(() {
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
        progressDialog.dismiss();
      });
    });
  }

  void _showDetails(int index) async {
    Service service = Service.fromJson(serviceList[index].toJson());
    loadSingleSeller(index);
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 5,
      message: const Text("Loading..."),
      title: null,
    );
    progressDialog.show();
    Timer(const Duration(seconds: 1), () {
      if (seller != null) {
        progressDialog.dismiss();
        int intId = int.parse(widget.user.id.toString());
        if (intId >= 1 && intId <= 10) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (content) => AdminDetailScreen(
                        user: widget.user,
                        service: service,
                        seller: seller,
                      )));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (content) => BuyerDetailScreen(
                        user: widget.user,
                        service: service,
                        seller: seller,
                      )));
        }
      }
      progressDialog.dismiss();
    });
  }

  void loadSingleSeller(int index) {
    http.post(Uri.parse("${ServerConfig.server}/php/loadseller.php"),
        body: {"sellerid": serviceList[index].userId}).then((response) {
      print(response.body);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == "success") {
        seller = User.fromJson(jsonResponse['data']);
      }
    });
  }
}
