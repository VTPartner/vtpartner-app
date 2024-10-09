import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';

class SearchingCabDriverScreen extends StatefulWidget {
  const SearchingCabDriverScreen({super.key});

  @override
  State<SearchingCabDriverScreen> createState() =>
      _SearchingCabDriverScreenState();
}

class _SearchingCabDriverScreenState extends State<SearchingCabDriverScreen> {
  var isLoading = false;
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;
//15.892953, 74.518013
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 30.4746,
  );
  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0.0;
  Set<Circle> circlesSet = {};
  Set<Marker> markersSet = {};

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 20);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0)),
                      child: SizedBox(
                        height: height - 550,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          zoomGesturesEnabled: true,
                          zoomControlsEnabled: true,
                          initialCameraPosition: _kGooglePlex,
                          onMapCreated: (GoogleMapController controller) async {
                            _controllerGoogleMap.complete(controller);
                            newGoogleMapController = controller;
                            print("controller::::$controller");
                            print(
                                "newGoogleMapController::::$newGoogleMapController");

                            //for black theme google map
                            // blackThemeGoogleMap();

                            setState(() {
                              bottomPaddingOfMap = 240;
                            });

                            locateUserPosition();
                          },
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
