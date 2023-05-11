import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import 'adminuserscreen.dart';

class SearchUserScreen extends StatefulWidget {
  final int list;
  const SearchUserScreen({super.key, required this.list});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  List<User> userList = <User>[];
  String titlecenter = "Search users";
  late double screenHeight, screenWidth, resWidth;
  TextEditingController searchController = TextEditingController();
  String search = "all";
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
                    _loadUsers(search, 1);
                  }
                },
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              search = searchController.text;
              if (search != "") {
                _loadUsers(search, 1);
              }
            },
          ),
        ),
      ),
      body: userList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : search == 'all'
              ? const Center(
                  child: Text("Search users",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Users ($numberofresult found)",
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
      itemCount: userList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            _showDetails(index);
          },
          child: userList[index].image == "no"
              ? customListItemTwo(
                  thumbnail: ClipOval(
                    child: Image.asset(
                      "assets/images/profile.png",
                      height: 150,
                      width: 150,
                    ),
                  ),
                  id: "ID: ${userList[index].id}",
                  name: userList[index].name.toString(),
                  index: index)
              : customListItemTwo(
                  thumbnail: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          "${ServerConfig.server}/assets/profileimages/${userList[index].id}.png",
                      placeholder: (context, url) =>
                          const LinearProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  id: "ID: ${userList[index].id}",
                  name: userList[index].name.toString(),
                  index: index),
        );
      },
    );
  }

  Widget customListItemTwo({
    required Widget thumbnail,
    required String id,
    required String name,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        height: 60,
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
                  id: id,
                  name: name,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _articleDescription({
    required String id,
    required String name,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
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
                id,
                maxLines: 2,
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

  void _loadUsers(String search, int pageNo) {
    curpage = pageNo;
    numofpage ?? 1;
    String file;
    if (widget.list == 1) {
      file = 'loadallusers.php';
    } else {
      file = 'loadallverifications.php';
    }
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/$file?search=$search&pageno=$pageNo&limit=$limit"),
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

          if (extractdata['users'] != null) {
            numofpage = int.parse(jsondata['numofpage']);
            numberofresult = int.parse(jsondata['numberofresult']);

            userList = <User>[];
            extractdata['users'].forEach((v) {
              userList.add(User.fromJson(v));
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No user found";
            userList.clear();
          }
        } else {
          titlecenter = "No user found";
          userList.clear();
        }
      } else {
        titlecenter = "No user found";
        userList.clear();
      }
      setState(() {
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
        progressDialog.dismiss();
      });
    });
  }

  void _showDetails(int index) async {
    User user = User.fromJson(userList[index].toJson());
    ProgressDialog progressDialog = ProgressDialog(context,
        blur: 5,
        message: const Text("Loading..."),
        title: null,
        dismissable: false);
    progressDialog.show();
    Timer(const Duration(seconds: 1), () {
      progressDialog.dismiss();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => AdminUserScreen(
                    user: user,
                    list: 3,
                  )));

      progressDialog.dismiss();
    });
  }
}
