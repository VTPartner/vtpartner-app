import 'dart:convert';

import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:http/http.dart' as http;

class SendNotificationService {
  static Future<void> sendNotificationUsingApi(
      {required String? token,
      required String? title,
      required String? body,
      required Map<String, dynamic>? data}) async {
    String serverKey = await GetServerKey().getServerKeyToken();
    String url =
        "https://fcm.googleapis.com/v1/projects/vt-partner-8317b/messages:send";
    var headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {"body": body, "title": title},
        "data": data
      }
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully.");
    } else {
      print('Notification not sent failed :${response.statusCode}');
    }
  }
}
