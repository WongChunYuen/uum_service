import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'orderhistorydetailscreen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;
  const OrderHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Order History"),
          // actions: [],
        ),
        body: StreamBuilder<List<MyOrder>>(
          stream: readOrder(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong ${snapshot.error}");
            } else if (snapshot.hasData) {
              final orders = snapshot.data!;
              return ListView(
                children: orders.map(buildOrder).toList(),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }

  Widget buildOrder(MyOrder order) => GestureDetector(
        onTap: () {
          _showHistoryDetails(order);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buy from: ${order.shopName}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(
                  height: 5,
                )
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.serviceName.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("x ${order.quantity}",
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        Text("RM ${order.price}",
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Colors.white,
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total amount:",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    Text("RM ${order.totalAmount}",
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Stream<List<MyOrder>> readOrder() => FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: widget.userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => MyOrder.fromJson(doc.data())).toList());

  void _showHistoryDetails(MyOrder order) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => OrderHistoryDetailScreen(
                  order: order,
                )));
  }
}
