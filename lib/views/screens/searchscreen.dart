import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import '../../models/shop.dart';
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
  List<Shop> shopList = <Shop>[];
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
                    _loadShops(search, 1);
                  }
                },
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              search = searchController.text;
              if (search != "") {
                _loadShops(search, 1);
              }
            },
          ),
        ),
      ),
      body: shopList.isEmpty
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
                    Expanded(child: myStatefulWidget()),
                  ],
                ),
    );
  }

  Widget myStatefulWidget() {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: shopList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            _showDetails(index);
          },
          child: customListItemTwo(
              thumbnail: CachedNetworkImage(
                imageUrl:
                    "${ServerConfig.server}/assets/serviceimages/${shopList[index].shopId}_1.png",
                placeholder: (context, url) => const LinearProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: shopList[index].shopName.toString(),
              subtitle: shopList[index].shopDesc.toString(),
              index: index),
        );
      },
    );
  }

  Widget customListItemTwo({
    required Widget thumbnail,
    required String title,
    required String subtitle,
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
                child: _articleDescription(
                  title: title,
                  subtitle: subtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _articleDescription({
    required String title,
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
            ],
          ),
        ),
      ],
    );
  }

  void _loadShops(String search, int pageNo) {
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

          if (extractdata['shops'] != null) {
            numofpage = int.parse(jsondata['numofpage']);
            numberofresult = int.parse(jsondata['numberofresult']);

            shopList = <Shop>[];
            extractdata['shops'].forEach((v) {
              shopList.add(Shop.fromJson(v));
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No service Available";
            shopList.clear();
          }
        } else {
          titlecenter = "No service Available";
          shopList.clear();
        }
      } else {
        titlecenter = "No service Available";
        shopList.clear();
      }
      setState(() {
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
        progressDialog.dismiss();
      });
    });
  }

  void _showDetails(int index) async {
    Shop shop = Shop.fromJson(shopList[index].toJson());
    loadSingleSeller(index);
    ProgressDialog progressDialog = ProgressDialog(context,
        blur: 5,
        message: const Text("Loading..."),
        title: null,
        dismissable: false);
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
                        shop: shop,
                        seller: seller,
                      )));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (content) => BuyerDetailScreen(
                        user: widget.user,
                        shop: shop,
                        seller: seller,
                      )));
        }
      }
      progressDialog.dismiss();
    });
  }

  void loadSingleSeller(int index) {
    http.post(Uri.parse("${ServerConfig.server}/php/loadseller.php"),
        body: {"sellerid": shopList[index].userId}).then((response) {
      print(response.body);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == "success") {
        seller = User.fromJson(jsonResponse['data']);
      }
    });
  }
}
