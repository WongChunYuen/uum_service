import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../screens/buyerscreen.dart';
import '../screens/loginscreen.dart';
import '../screens/profilescreen.dart';
import 'EnterExitRoute.dart';

// import '../screens/profilescreen.dart';
// import '../screens/sellerscreen.dart';

class MainMenuWidget extends StatefulWidget {
  final User user;
  const MainMenuWidget({super.key, required this.user});

  @override
  State<MainMenuWidget> createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      elevation: 10,
      child: verifyLogin(),
    );
  }

  Widget verifyLogin() {
    if (widget.user.id.toString() == "0" &&
        widget.user.email.toString() == "unregistered") {
      return ListView(children: [
        const UserAccountsDrawerHeader(
          accountEmail: Text(""),
          accountName: Text("Please login"),
          currentAccountPicture: CircleAvatar(
            radius: 30.0,
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
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help Center'),
          onTap: () {
            Navigator.pop(context);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (content) => const ProfileScreen()));
            // Navigator.push(
            //     context,
            //     EnterExitRoute(
            //         exitPage: BuyerScreen(user: widget.user),
            //         enterPage: ProfileScreen(
            //           user: widget.user,
            //         )));
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Setting'),
          onTap: () {
            Navigator.pop(context);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (content) => const ProfileScreen()));
            // Navigator.push(
            //     context,
            //     EnterExitRoute(
            //         exitPage: BuyerScreen(user: widget.user),
            //         enterPage: ProfileScreen(
            //           user: widget.user,
            //         )));
          },
        ),
      ]);
    } else {
      return ListView(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(widget.user.email.toString()),
            accountName: Text(widget.user.name.toString()),
            currentAccountPicture: const CircleAvatar(
              radius: 30.0,
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
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (content) => const SellerScreen()));
              // Navigator.push(
              //     context,
              //     EnterExitRoute(
              //         exitPage: BuyerScreen(user: widget.user),
              //         enterPage: SellerScreen(user: widget.user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Order List'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (content) => const ProfileScreen()));
              // Navigator.push(
              //     context,
              //     EnterExitRoute(
              //         exitPage: BuyerScreen(user: widget.user),
              //         enterPage: ProfileScreen(
              //           user: widget.user,
              //         )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (content) => const ProfileScreen()));
              // Navigator.push(
              //     context,
              //     EnterExitRoute(
              //         exitPage: BuyerScreen(user: widget.user),
              //         enterPage: ProfileScreen(
              //           user: widget.user,
              //         )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help Center'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (content) => const ProfileScreen()));
              // Navigator.push(
              //     context,
              //     EnterExitRoute(
              //         exitPage: BuyerScreen(user: widget.user),
              //         enterPage: ProfileScreen(
              //           user: widget.user,
              //         )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Setting'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (content) => const ProfileScreen()));
              // Navigator.push(
              //     context,
              //     EnterExitRoute(
              //         exitPage: BuyerScreen(user: widget.user),
              //         enterPage: ProfileScreen(
              //           user: widget.user,
              //         )));
            },
          ),
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
        email: "unregistered",
        name: "unregistered",
        address: "na",
        phone: "0123456789",
        regdate: "0");
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (content) => BuyerScreen(user: user)));
  }
}
