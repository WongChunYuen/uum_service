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
import 'searchuserscreen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> userList = <User>[];
  String titlecenter = "Loading...";
  var color;
  var numofpage, curpage = 1;
  int numberofresult = 0;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadUsers(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User List"),
        actions: [
          searchUser(), // search user (need to change it later)
        ],
      ),
      body: userList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Total users: $numberofresult",
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
                          onPressed: () => {_loadUsers(index + 1)},
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
      itemCount: userList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            _showDetails(index);
          },
          child: userList[index].image == "no"
              ? CustomListItemTwo(
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
              : CustomListItemTwo(
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

  Widget CustomListItemTwo({
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
                child: _ArticleDescription(
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

  Widget _ArticleDescription({
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

  void _loadUsers(int pageNo) {
    curpage = pageNo;
    numofpage ?? 1;
    http
        .get(
      Uri.parse(
          "${ServerConfig.server}/php/loadallusers.php?search=all&pageno=$pageNo&limit=$limit"),
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
            titlecenter = "No service Available";
            userList.clear();
          }
        } else {
          titlecenter = "No service Available";
          userList.clear();
        }
      } else {
        titlecenter = "No service Available";
        userList.clear();
      }
      setState(() {
        DefaultCacheManager manager = DefaultCacheManager();
        manager.emptyCache();
        progressDialog.dismiss();
      });
    });
  }

  Widget searchUser() {
    return IconButton(onPressed: _gotoSearch, icon: const Icon(Icons.search));
  }

  void _gotoSearch() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => const SearchUserScreen(
                  list: 1,
                )));
  }

  void _showDetails(int index) async {
    User user = User.fromJson(userList[index].toJson());
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 5,
      message: const Text("Loading..."),
      title: null,
    );
    progressDialog.show();
    Timer(const Duration(seconds: 1), () {
      progressDialog.dismiss();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => AdminUserScreen(
                    user: user,
                    list: 1,
                  )));
      progressDialog.dismiss();
    });
    setState(() {});
  }
}
