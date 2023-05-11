import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:uum_service/views/screens/orderlistscreen.dart';
import '../../models/shop.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'detailscreen.dart';
import 'newshopscreen.dart';

class SellerScreen extends StatefulWidget {
  final User user;
  const SellerScreen({super.key, required this.user});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  List<Shop> shopList = <Shop>[];
  String titlecenter = "Loading";
  late double screenHeight, screenWidth, resWidth;
  int rowcount = 2;

  Future refresh() async {
    _loadShops();
  }

  @override
  void initState() {
    super.initState();
    _loadShops();
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
      appBar: AppBar(title: const Text("My Shops"), actions: [
        PopupMenuButton(itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("New Shop"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("Order List"),
            ),
          ];
        }, onSelected: (value) {
          if (value == 0) {
            _createNewShop();
          } else if (value == 1) {
            _goOrderList();
          }
        }),
      ]),
      body: shopList.isEmpty
          ? titlecenter == "Loading"
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Your current shop (${shopList.length} found)",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: refresh, child: myStatefulWidget())),
              ],
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton(
            onPressed: () {
              _createNewShop();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void _createNewShop() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => NewShopScreen(
                  user: widget.user,
                )));
    _loadShops();
  }

  void _goOrderList() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => OrderListScreen(
                  sellerId: widget.user.id.toString(),
                )));
    _loadShops();
  }

  void _loadShops() {
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/load_shop.php?userid=${widget.user.id}"),
    )
        .then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          var extractdata = jsondata['data'];
          if (extractdata['shops'] != null) {
            shopList = <Shop>[];
            extractdata['shops'].forEach((v) {
              shopList.add(Shop.fromJson(v));
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No Shop Available";
            shopList.clear();
          }
        } else {
          titlecenter = "No Shop Available";
          shopList.clear();
        }
      }
      setState(() {
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
      });
    });
  }

  Future<void> _showDetails(int index) async {
    Shop shop = Shop.fromJson(shopList[index].toJson());

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => DetailsScreen(
                  shop: shop,
                  user: widget.user,
                )));
    _loadShops();
  }

  void _deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            "Delete ${truncateString(shopList[index].shopName.toString(), 15)}",
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
                    _deleteShop(index);
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

  void _deleteShop(index) {
    try {
      http.post(Uri.parse("${ServerConfig.server}/php/delete_shop.php"), body: {
        "shopid": shopList[index].shopId,
      }).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "Success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          _loadShops();
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
