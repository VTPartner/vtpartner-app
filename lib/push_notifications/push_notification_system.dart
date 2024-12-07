import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as serviceControl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/global/global.dart' as glb;

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future intializeCloudMessaging() async {
    //1.Terminated - When app is completed closed and opened directly from the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //request ride request information - user information who request a ride
      }
    });

    //2. Foreground - When app is open and receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {});

    //3. Background - When app is in background and open directly from the notification.
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage? remoteMessage) {});
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
}
