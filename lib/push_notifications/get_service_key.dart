import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as serviceControl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/global/global.dart' as glb;

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
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
