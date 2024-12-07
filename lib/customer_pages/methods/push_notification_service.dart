import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as serviceControl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/global/global.dart' as glb;

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notification permission granted.");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("Provisional notification permission granted.");
    } else {
      print("Notification permission denied.");
    }
  }

  static Future<String> getAccessToken() async {
    List<String> scopes = [
      // "https://www.googleapis.com/auth/userinfo.email",
      // "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(glb.serviceAccountJson),
        scopes);

    //get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(glb.serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID) async {
    final pref = await SharedPreferences.getInstance();

    var customer_name = pref.getString("customer_name");
    // var pickupLocation = Provider.of<AppInfo>(context, listen: false)
    //     .userPickupLocation!
    //     .locationName
    //     .toString();
    // var dropOffLocation = Provider.of<AppInfo>(context, listen: false)
    //     .userDropOfLocation!
    //     .locationName
    //     .toString();

    final String serverAccessTokenKey = await getAccessToken();

    String endPointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/vt-partner-4a2b1/message:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "New Trip Request from ${customer_name}",
          'body': "Pickup Location:"
        },
        'data': {'tripID': tripID}
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endPointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully.");
    } else {
      print('Notification not sent failed :${response.statusCode}');
    }
  }
}
