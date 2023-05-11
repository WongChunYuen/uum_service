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
import '../shared/mainmenu.dart';
import 'buyerdetailscreen.dart';
import 'searchscreen.dart';

class BuyerScreen extends StatefulWidget {
  final User user;
  const BuyerScreen({super.key, required this.user});

  @override
  State<BuyerScreen> createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  List<Shop> shopList = <Shop>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  var seller;
  var color;
  var numofpage, curpage = 1;
  int numberofresult = 0;
  int page = 1;
  int limit = 6;
  final controller = ScrollController();
  bool isLoading = false;
  bool hasMore = true;

  Future refresh() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 1;
      shopList.clear();
    });
    fetch();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadShops(page);
    });

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        if (hasMore) {
          page++;
          fetch();
        }
      }
    });
  }

  Future fetch() async {
    if (isLoading) return;
    isLoading = true;
    _loadShops(page);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            GestureDetector(onTap: refresh, child: const Text("UUM Service")),
        actions: [
          searchShop(),
        ],
      ),
      body: shopList.isEmpty
          ? titlecenter == "No service Available"
              ? RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView(
                    children: [
                      Center(
                        child: Text(
                          titlecenter,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator())
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
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: refresh, child: myStatefulWidget())),
              ],
            ),
      drawer: MainMenuWidget(user: widget.user),
    );
  }

  Widget myStatefulWidget() {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(10.0),
      itemCount: shopList.length + 1,
      itemBuilder: (context, index) {
        if (index < shopList.length) {
          return InkWell(
            onTap: () {
              _showDetails(index);
            },
            child: customListItemTwo(
                thumbnail: CachedNetworkImage(
                  imageUrl:
                      "${ServerConfig.server}/assets/serviceimages/${shopList[index].shopId}_1.png",
                  placeholder: (context, url) =>
                      const LinearProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                title: shopList[index].shopName.toString(),
                subtitle: shopList[index].shopDesc.toString(),
                index: index),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: hasMore
                  ? const CircularProgressIndicator()
                  : const Text("No more services"),
            ),
          );
        }
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

  void _loadShops(int pageNo) {
    curpage = pageNo;
    numofpage ?? 1;
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/loadallservices.php?search=all&pageno=$pageNo&limit=$limit"),
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

            List newShopList = <Shop>[];
            newShopList.clear();
            extractdata['shops'].forEach((v) {
              newShopList.add(Shop.fromJson(v));
              shopList.add(Shop.fromJson(v));
            });
            titlecenter = "Found";
            if (newShopList.length < limit) {
              hasMore = false;
            }
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (content) => BuyerDetailScreen(
                      user: widget.user,
                      shop: shop,
                      seller: seller,
                    )));
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

  Widget searchShop() {
    return IconButton(onPressed: _gotoSearch, icon: const Icon(Icons.search));
  }

  void _gotoSearch() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => SearchScreen(user: widget.user)));
  }
}
