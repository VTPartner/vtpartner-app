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
import 'package:vt_partner/utils/app_styles.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
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

    LatLng latLngPosition =
        LatLng(
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

    newGoogleMapController?.dispose();
    super.dispose();
  }

  double searchLocationContainerHeight = 220.0;
  bool isOnline = false; // Default state

  void _toggleSwitch(bool value) {
    // Show confirmation dialog before toggling
    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Change Status'),
          content: Text(value
              ? 'Do you want to go online?'
              : 'Do you want to go offline?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: nunitoSansStyle.copyWith(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Confirm',
                style: nunitoSansStyle.copyWith(
                    color: isOnline ? Colors.red : Colors.green),
              ),
              onPressed: () {
                setState(() {
                  isOnline = value; // Update the state
                });
                if (isOnline) {
                  driverIsOnlineNow(); //Updating Driver Current Location and Searching for new ride requests
                  updateDriversLocationAtRealTime(); // It will start sending realtime lat lng
                } else {
                  driverIsOfflineNow();
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      bottomPaddingOfMap = 10;
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
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0)),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  //Show Drawer screen here
                                  Navigator.pushNamed(
                                      context, AgentSettingsRoute);
                                },
                                icon: Icon(
                                  Icons.menu_outlined,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Ink(
                                width: _width - 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Hello, Justin",
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16.5),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: isOnline,
                                onChanged: _toggleSwitch,
                                activeColor:
                                    Colors.green, // Color when switch is on
                                inactiveThumbColor:
                                    Colors.red, // Color when switch is off
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0)),
                            color: isOnline ? Colors.green : Colors.red),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Ink(
                                width: _width - 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isOnline ? Icons.login : Icons.logout,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          isOnline
                                              ? "You are Online Now"
                                              : "You are Offline Now",
                                          style: nunitoSansStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 14.5),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = pos;
    //Update driver Status to Online and send his lat and lng where driver_id
    var latitude = driverCurrentPosition!.latitude;
    var longitude = driverCurrentPosition!.longitude;
    print("driver lat::$latitude");
    print("driver lng::$longitude");

    //And he is searching for a new ride . But first check his current status in backend
  }

  updateDriversLocationAtRealTime() {
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
      print("driver cur_lat::$latitude");
      print("driver cur_lng::$longitude");

      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    });
  }

  driverIsOfflineNow() {
    //Async to make him go offline
    Future.delayed(const Duration(milliseconds: 2000), () {
      streamSubscriptionPosition?.cancel();
      // MyApp.restartApp(context);
    });
  }
}
