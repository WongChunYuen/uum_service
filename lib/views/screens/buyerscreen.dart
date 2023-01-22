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
          searchService(),
        ],
      ),
      body: const Center(child: Text("No services yet")),
      drawer: MainMenuWidget(user: widget.user),
    );
  }

  Widget searchService() {
    return IconButton(onPressed: _gotoSearch, icon: const Icon(Icons.search));
  }

  void _gotoSearch() {
    Navigator.push(
        context, MaterialPageRoute(builder: (content) => LoginScreen()));
  }
}
