import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../shared/mainmenu.dart';
import 'loginscreen.dart';
// import 'ownerscreen.dart';
// import 'profilescreen.dart';

// Buyer screen for the UUM Service application
class BuyerScreen extends StatefulWidget {
  final User user;
  const BuyerScreen({super.key, required this.user});

  @override
  State<BuyerScreen> createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UUM Service"),
        actions: [
          verifyLogin(),
        ],
      ),
      body: const Center(child: Text("No services yet")),
      drawer: MainMenuWidget(user: widget.user),
    );
  }

  Widget verifyLogin() {
    if (widget.user.id.toString() == "0" &&
        widget.user.email.toString() == "unregistered") {
      return IconButton(
          onPressed: _loginButton, icon: const Icon(Icons.account_circle));
    } else {
      return PopupMenuButton<int>(
        icon: const Icon(Icons.account_circle),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 1,
            child: Text('Profile'),
          ),
          const PopupMenuItem(
            value: 2,
            child: Text('My Homestay'),
          ),
          const PopupMenuItem(
            value: 3,
            child: Text('Logout'),
          ),
        ],
        onSelected: (value) {
          if (value == 1) {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (content) => ProfileScreen(user: widget.user)));
          } else if (value == 2) {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (content) => OwnerScreen(user: widget.user)));
          } else if (value == 3) {
            _logoutUser();
          }
        },
      );
    }
  }

  // login method to let user go to login screen
  void _loginButton() {
    Navigator.push(
        context, MaterialPageRoute(builder: (content) => const LoginScreen()));
  }

  // Method that let user to log out
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
