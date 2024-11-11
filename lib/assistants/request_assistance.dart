import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  // static Future<Map<String, dynamic>> postRequest(
  //     String url, Map<String, dynamic> body) async {
  //   print("endPoint::${url}");

  //   // Check internet connectivity
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     Fluttertoast.showToast(
  //       msg: "No internet connection. Please check your network.",
  //       toastLength: Toast.LENGTH_LONG,
  //     );
  //     throw Exception("No internet connection");
  //   }

  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json;charset=UTF-8',
  //     },
  //     body: jsonEncode(body),
  //   );
  //   print("response.statusCode::${response.statusCode}");

  //    if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   }
  // }

  static Future<Map<String, dynamic>> postRequest(
      String url, Map<String, dynamic> body) async {
    print("endPoint::${url}");
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print("response.statusCode::${response.statusCode}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      if (response.statusCode == 404) {
        throw Exception('No Data Found');
      } else if (response.statusCode == 405) {
        throw Exception('Method not allowed');
      } else if (response.statusCode == 500) {
        throw Exception('Something went wrong');
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load data. Status code: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
        );
        throw Exception('Failed to load data');
      }
    }
  }

}
