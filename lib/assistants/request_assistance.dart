import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  

  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    //Success
    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body; //JSON Data

        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      } else {
        return "Error";
      }
    } catch (e) {
      print("Current address Error::${e.toString()}");
      return "Error";
    }
  }
}
