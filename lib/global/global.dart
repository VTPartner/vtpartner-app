library global;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';

Future<BitmapDescriptor> getMarkerIconFromUrl(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
      ui.FrameInfo fi = await codec.getNextFrame();
      final data = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    } else {
      throw Exception("Failed to load image");
    }
  } catch (e) {
    print("Error loading marker icon from URL: $e");
    return BitmapDescriptor.defaultMarker;
  }
}


StreamSubscription<Position>? streamSubscriptionPosition;
var devMode = 0; // Change this to 1 for development mode
late String serverEndPoint;
late String serverEndPointImage;

void initializeEndpoints() {
  if (devMode == 1) {
    serverEndPoint = "http://77.37.47.156:8000/api/vt_partner";
    serverEndPointImage = "http://77.37.47.156:8000/api/vt_partner";
  } else {
    serverEndPoint = "https://www.vtpartner.in/api/vt_partner";
    serverEndPointImage = "https://www.vtpartner.in/api/vt_partner";
  }
}

void showSnackBar(BuildContext context, String alertTxt, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
    text,
    style: robotoStyle.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold),
    textAlign: TextAlign.center,
  )));
}

var customer_mobile_no = "";
var delivery_agent_mobile_no = "";

void showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    gravity: ToastGravity.TOP,
    backgroundColor:
        Colors.black.withOpacity(0.7), // Customize background color
    textColor: Colors.white, // Customize text color
    toastLength: Toast.LENGTH_SHORT, // Duration of the toast
    fontSize: 16.0, // Customize font size
  );
}

