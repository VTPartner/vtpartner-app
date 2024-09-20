import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetUserCurrentLocation extends StatefulWidget {
  const GetUserCurrentLocation({super.key});

  @override
  State<GetUserCurrentLocation> createState() => _GetUserCurrentLocationState();
}

class _GetUserCurrentLocationState extends State<GetUserCurrentLocation> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 14.4746,
  );

  final List<Marker> _markers = <Marker>[
    // Marker(
    //     markerId: MarkerId("1"),
    //     position: LatLng(15.892953, 74.518013),
    //     infoWindow: InfoWindow(title: "The title of marker"))
  ];

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error:::" + error.toString());
    });

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Current Location"),
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        mapType: MapType.normal,
        markers: Set<Marker>.of(_markers),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getUserCurrentLocation().then((value) async {
            print(value.latitude.toString() + " " + value.longitude.toString());

            _markers.add(Marker(
                markerId: MarkerId("2"),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: InfoWindow(title: "My Current Location")));

            CameraPosition cameraPosition = CameraPosition(
                target: LatLng(value.latitude, value.longitude), zoom: 16);

            final GoogleMapController controller = await _controller.future;

            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

            setState(() {});
          });
        },
        child: Icon(Icons.local_activity),
      ),
    );
  }
}
