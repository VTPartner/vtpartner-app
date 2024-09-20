import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:custom_info_window/custom_info_window.dart';

class CustomMarkerScreen extends StatefulWidget {
  const CustomMarkerScreen({super.key});

  @override
  State<CustomMarkerScreen> createState() => _CustomMarkerScreenState();
}

class _CustomMarkerScreenState extends State<CustomMarkerScreen> {
  // CustomInfoWindowController _customInfoWindowController =
  //     CustomInfoWindowController();

  final Completer<GoogleMapController> _controller = Completer();

  Uint8List? markerImage;

  List<String> images = [
    'assets/icons/box_truck.png',
    'assets/icons/box_truck.png',
    'assets/icons/box_truck.png'
  ];

  final List<Marker> _markers = <Marker>[];
  final List<LatLng> _latlng = <LatLng>[
    LatLng(15.892953, 74.518013),
    LatLng(15.8765793, 74.4862655),
    LatLng(15.8376978, 74.5009168),
  ];
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 14.4746,
  );

  Future<Uint8List> getbytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
    for (int i = 0; i < images.length; i++) {
      final Uint8List markerIcon = await getbytesFromAssets(images[i], 25);

      _markers.add(Marker(
          markerId: MarkerId(i.toString()),
          icon: BitmapDescriptor.bytes(markerIcon),
          position: _latlng[i],
          infoWindow:
              InfoWindow(title: "This is title marker : " + i.toString())));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: GoogleMap(
              markers: Set<Marker>.from(_markers),
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              //Use this for custom markers only
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              }

              //Using this for Custom Info Window
              // onMapCreated: (GoogleMapController controller) {
              //   _customInfoWindowController.googleMapController = controller;
              // }
              )),
    );
  }
}
