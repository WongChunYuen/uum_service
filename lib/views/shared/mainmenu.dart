import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';
import '../screens/buyerscreen.dart';
import '../screens/loginscreen.dart';
import '../screens/profilescreen.dart';
import '../screens/sellerscreeen.dart';
import 'EnterExitRoute.dart';

class MainMenuWidget extends StatefulWidget {
  final User user;
  const MainMenuWidget({super.key, required this.user});

  @override
  State<MainMenuWidget> createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {
  var _imageStatus;

  @override
  void initState() {
    super.initState();
    _imageStatus = widget.user.image;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      elevation: 10,
      child: verifyLogin(),
    );
  }

  Widget verifyLogin() {
    int intId = int.parse(widget.user.id.toString());
    if (widget.user.id.toString() == "0" &&
        widget.user.email.toString() == "unregistered") {
      return ListView(children: [
        const UserAccountsDrawerHeader(
          accountEmail: Text(""),
          accountName: Text(" Please login"),
          currentAccountPicture: CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage("assets/images/profile.png"),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.account_circle_rounded),
          title: const Text('Login'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                EnterExitRoute(
                    exitPage: BuyerScreen(user: widget.user),
                    enterPage: const LoginScreen()));
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.help_outline),
        //   title: const Text('Help Center'),
        //   onTap: () {
        //     Navigator.pop(context);

        //   },
        // ),
        // ListTile(
        //   leading: const Icon(Icons.settings_outlined),
        //   title: const Text('Setting'),
        //   onTap: () {
        //     Navigator.pop(context);

        //   },
        // ),
      ]);
    }
    if (intId >= 1 && intId <= 10) {
      return ListView(
        children: [
          _imageStatus == 'no'
              ? UserAccountsDrawerHeader(
                  accountEmail: Text("  ${widget.user.email}"),
                  accountName: Text("  ${widget.user.name}"),
                  currentAccountPicture: const CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage("assets/images/profile.png"),
                  ),
                )
              : UserAccountsDrawerHeader(
                  accountEmail: Text("  ${widget.user.email}"),
                  accountName: Text("  ${widget.user.name}"),
                  currentAccountPicture: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                          "${ServerConfig.server}/assets/profileimages/${widget.user.id}.png",
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, size: 30),
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 30,
                      ),
                    ),
                  ),
                ),
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  EnterExitRoute(
                      exitPage: BuyerScreen(user: widget.user),
                      enterPage: ProfileScreen(user: widget.user)));
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.help_outline),
          //   title: const Text('Help Center'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.settings_outlined),
          //   title: const Text('Setting'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              Navigator.pop(context);
              _logoutUser();
            },
          ),
        ],
      );
    } else {
      return ListView(
        children: [
          _imageStatus == 'no'
              ? UserAccountsDrawerHeader(
                  accountEmail: Text("  ${widget.user.email}"),
                  accountName: Text("  ${widget.user.name}"),
                  currentAccountPicture: const CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage("assets/images/profile.png"),
                  ),
                )
              : UserAccountsDrawerHeader(
                  accountEmail: Text("  ${widget.user.email}"),
                  accountName: Text("  ${widget.user.name}"),
                  currentAccountPicture: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                          "${ServerConfig.server}/assets/profileimages/${widget.user.id}.png",
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, size: 30),
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 30,
                      ),
                    ),
                  ),
                ),
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  EnterExitRoute(
                      exitPage: BuyerScreen(user: widget.user),
                      enterPage: ProfileScreen(user: widget.user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.sell),
            title: const Text('Seller'),
            onTap: () {
              if (widget.user.verify == 'no') {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      title: const Text(
                        "Please verify your account with MyKad first",
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        Center(
                          child: TextButton(
                            child: const Text(
                              "OK",
                              style: TextStyle(),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else if (widget.user.verify == 'pending') {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      title: const Text(
                        "Please wait for the admin to approve your account verification",
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        Center(
                          child: TextButton(
                            child: const Text(
                              "OK",
                              style: TextStyle(),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    EnterExitRoute(
                        exitPage: BuyerScreen(user: widget.user),
                        enterPage: SellerScreen(user: widget.user)));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Order List'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.help_outline),
          //   title: const Text('Help Center'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.settings_outlined),
          //   title: const Text('Setting'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              Navigator.pop(context);
              _logoutUser();
            },
          ),
        ],
      );
    }
  }

  void _logoutUser() {
    User user = User(
        id: "0",
        accstatus: "activate",
        image: "no",
        email: "unregistered",
        name: "unregistered",
        address: "na",
        phone: "0123456789",
        verify: "no",
        regdate: "0");
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (content) => BuyerScreen(user: user)));
  }
}
