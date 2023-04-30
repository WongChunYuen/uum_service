import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> setupFirebase() async {
    // Initialize Firebase Cloud Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _fcm.requestPermission();
    await _fcm.subscribeToTopic('all');

    // Initialize Firestore listener
    _db.collection('orders').snapshots().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          final title = 'New Order';
          final body =
              'A new order has been placed by ${data!['customerName']}';

          // Send a push notification
          _sendPushNotification(title, body);
        }
      });
    });
  }

  Future<void> _sendPushNotification(String title, String body) async {
    // TODO: Implement sending push notifications
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Handle background message
  }
}
