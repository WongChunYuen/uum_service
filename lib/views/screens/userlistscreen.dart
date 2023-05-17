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
  String titlecenter = "Loading";
  var color;
  var numofpage, curpage = 1;
  int numberofresult = 0;
  int page = 1;
  int limit = 10;
  final controller = ScrollController();
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadUsers(page);
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
    _loadUsers(page);
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
        title: const Text("User List"),
        actions: [
          searchUser(), // search user (need to change it later)
        ],
      ),
      body: userList.isEmpty
          ? titlecenter == "No user Available"
              ? Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)))
              : const Center(child: CircularProgressIndicator())
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
                Expanded(child: myStatefulWidget()),
              ],
            ),
    );
  }

  Widget myStatefulWidget() {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(10.0),
      itemCount: userList.length + 1,
      itemBuilder: (context, index) {
        if (index < userList.length) {
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
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: hasMore
                  ? const CircularProgressIndicator()
                  : const Text("No more users"),
            ),
          );
        }
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

            List newUserList = <User>[];
            newUserList.clear();
            extractdata['users'].forEach((v) {
              newUserList.add(User.fromJson(v));
              userList.add(User.fromJson(v));
            });
            titlecenter = "Found";
            if (newUserList.length < limit) {
              hasMore = false;
            }
          } else {
            titlecenter = "No user Available";
            userList.clear();
          }
        } else if (jsondata['status'] == 'noMore') {
          hasMore = false;
        } else {
          titlecenter = "No user Available";
          userList.clear();
        }
      } else {
        titlecenter = "No user Available";
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
                    list: 1,
                  )));
    });
    setState(() {});
  }
}
