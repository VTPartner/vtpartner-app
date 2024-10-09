import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/global/global.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_colors.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/circular_network_image.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/round_textfield.dart';

class CabHomeScreen extends StatefulWidget {
  const CabHomeScreen({super.key});

  @override
  State<CabHomeScreen> createState() => _CabHomeScreenState();
}

class _CabHomeScreenState extends State<CabHomeScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;
//15.892953, 74.518013
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 14.4746,
  );

  blackThemeController() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  Position? driverCurrentPosition;

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  Set<Marker> markersSet = {};
  BitmapDescriptor? customMarkerIcon;

  double bottomPaddingOfMap = 0.0;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // Add custom marker at the user's current location
    Marker userMarker = Marker(
      markerId: MarkerId("currentLocation"),
      position: latLngPosition,
      icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: "You are here"),
    );

    setState(() {
      markersSet.add(userMarker);
    });
  }

  // Set custom marker icon for the user's location
  void setCustomMarkerIcon() async {
    customMarkerIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      'assets/icons/3d_location.png', // Replace with your own marker asset
    );
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setCustomMarkerIcon();
    checkIfLocationPermissionAllowed();
  }

  // Stop location updates and clean up when screen is disposed
  @override
  void dispose() {
    // Cancel the position stream subscription
    streamSubscriptionPosition?.cancel();
    newGoogleMapController?.dispose();
    super.dispose();
  }

  double searchLocationContainerHeight = 220.0;
  bool isOnline = false; // Default state

  @override
  Widget build(BuildContext context) {
    var appInfo = Provider.of<AppInfo>(context);

    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: _height,
                child: GoogleMap(
                  padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                  mapType: MapType.normal,
                  myLocationEnabled: true, // Disable default blue dot
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  markers: markersSet, // Add custom markers here
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    setState(() {
                      newGoogleMapController = controller;
                    });
                    //For Black Theme Google Map
                    //blackThemeController();

                    setState(() {
                      bottomPaddingOfMap = 120.0;
                    });
                    //Get Users Current Location
                    locateUserPosition();
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.menu,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        CircularNetworkImage(
                            radius: 25,
                            imageUrl:
                                'https://preview.keenthemes.com/metronic-v4/theme_rtl/assets/pages/media/profile/profile_user.jpg')
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, CabDestinationLocationSearchRoute);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.7), // Shadow color
                              offset: Offset(0, 3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: ThemeClass.facebookBlue,
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(
                                'Where are you going ?',
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: 16.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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

  updateUsersLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      if (isOnline == true) {
        // Geofire.setLocation(driverID, driverCurrentPosition!.latitude,
        //     driverCurrentPosition!.longitude); // this is used for firebase realtime database
        // Update in table also
      }

      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      var latitude = driverCurrentPosition!.latitude;
      var longitude = driverCurrentPosition!.longitude;
      print("cab user cur_lat::$latitude");
      print("cab user cur_lng::$longitude");

      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    });
  }
}
