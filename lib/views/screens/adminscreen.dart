import 'package:flutter/material.dart';
import 'package:uum_service/views/shared/mainmenu.dart';

import '../../models/user.dart';
import 'servicelistscreen.dart';
import 'userlistscreen.dart';
import 'verificationlistscreen.dart';

class AdminScreen extends StatefulWidget {
  final User user;
  const AdminScreen({super.key, required this.user});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => const UserListScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  width: 190,
                  height: 130,
                  child: Card(
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'User List',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) =>
                              ServiceListScreen(user: widget.user)));
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  width: 190,
                  height: 130,
                  child: Card(
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Service List',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) =>
                              const VerificationListScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  width: 190,
                  height: 130,
                  child: Card(
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Verification List',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: MainMenuWidget(user: widget.user),
    );
  }
}
