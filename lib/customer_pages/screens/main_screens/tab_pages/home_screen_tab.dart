import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/customer_pages/screens/contacts_screens/contact_screen.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'dart:async';

import '../../../../utils/app_styles.dart';
import '../../../../widgets/body_text1.dart';
import '../../../../widgets/description_text.dart';
import '../../../../widgets/dotted_vertical_divider.dart';
import '../../../../widgets/sub_title_text.dart';

class HomeScreenTabPage extends StatefulWidget {
  const HomeScreenTabPage({super.key});

  @override
  State<HomeScreenTabPage> createState() => _HomeScreenTabPageState();
}

class _HomeScreenTabPageState extends State<HomeScreenTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  bool _isMapControllerSet = false;

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

  Position? userCurrentPosition;

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  double bottomPaddingOfMap = 0.0;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  Future<void> _getUserLocationAndAddress() async {
    try {
      Position position = await getUserCurrentLocation();
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoOrdinates(
              position!, context);
      print("MyHomeLocation::" + humanReadableAddress);
    } catch (e) {
      setState(() {
        _address = "Error: ${e.toString()}";
      });
    }
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error:::" + error.toString());
    });

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String _address = "Loading...";
  AppInfo? appInfo;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfLocationPermissionAllowed();
    _getUserLocationAndAddress();
   
  }

  double searchLocationContainerHeight = 220.0;
  var isServiceProvided = true;

  @override
  Widget build(BuildContext context) {
    appInfo = Provider.of<AppInfo>(context);
    
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemeClass.backgroundColorLightPink,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: _width,
                  height:
                      isServiceProvided == true ? _height / 2.5 : _height / 1,
                  child: GoogleMap(
                    padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      if (!_isMapControllerSet) {
                        _controllerGoogleMap.complete(controller);
                        newGoogleMapController = controller;
                        _isMapControllerSet = true;

                        // For Black Theme Google Map
                        // blackThemeController();

                        setState(() {
                          bottomPaddingOfMap = 0.0;
                        });
                        // Get Users Current Location
                        locateUserPosition();
                      }
                    },
                  ),
                
                ),
                isServiceProvided == true
                    ? SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.3), // Shadow color
                                  offset: Offset(0, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    "assets/icons/green_dot.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(2.0),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, PickUpAddressRoute);
                                      },
                                      child: Ink(
                                        width: _width - 120,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Your Current Location",
                                              style: nunitoSansStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                  fontSize: 11.5),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context)
                                                          .userCurrentLocation !=
                                                      null
                                                  ? Provider.of<AppInfo>(
                                                          context)
                                                      .userCurrentLocation!
                                                      .locationName!
                                                  : "Loading ...",
                                              style: nunitoSansStyle.copyWith(
                                                  color: Colors.grey[800],
                                                  fontSize: 11.5),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(
                                  //   width: 5.0,
                                  // ),
                                  // Image.asset(
                                  //   "assets/icons/gps.png",
                                  //   width: 20,
                                  //   height: 20,
                                  // ),
                                  const SizedBox(
                                    width: 8.0,
                                  ),
                                  Image.asset(
                                    "assets/icons/notify.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.red),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(2.0),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, PickUpAddressRoute);
                                      },
                                      child: Ink(
                                        width: _width - 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "We currently do not offer services for your current pickup location.",
                                              style: nunitoSansStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14.5),
                                              overflow: TextOverflow.visible,
                                            ),
                                            Text(
                                              _address,
                                              style: nunitoSansStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14.5),
                                              overflow: TextOverflow.visible,
                                            ),
                                            Text(
                                              "Please click here to select an alternative pickup location.",
                                              style: nunitoSansStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 12.5),
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
              ],
            ),
            isServiceProvided == true
                ? Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: _width,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Our Services",
                                style: nunitoSansStyle.copyWith(
                                    color: ThemeClass.backgroundColorDark,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize),
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0)),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey
                                  //         .withOpacity(0.2), // Light shadow color
                                  //     spreadRadius: 2,
                                  //     blurRadius: 8,
                                  //     offset: const Offset(
                                  //         0, 4), // Changes the shadow position
                                  //   ),
                                  // ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, ServiceTypesRoute);
                                        },
                                        child: Column(
                                          children: [
                                            ClipOval(
                                              child: SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Image.network(
                                                  "https://d3apkeya39jz4k.cloudfront.net/trucks_293a94a860_cc4b2d6d06.webp",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SubTitleText(subTitle: 'Goods'),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, CabHomeRoute);
                                        },
                                        child: Column(
                                          children: [
                                            ClipOval(
                                              child: SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Image.network(
                                                  "https://d3apkeya39jz4k.cloudfront.net/Pn_M_56aa8e7af2_4b05aeef37.webp",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SubTitleText(subTitle: 'Ride Now'),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          ClipOval(
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child: Image.network(
                                                "https://d3apkeya39jz4k.cloudfront.net/all_india_courier_service_3b0f4df07f.webp",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SubTitleText(subTitle: 'Vendors'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: kHeight,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: _width,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tracking Parcel",
                                style: nunitoSansStyle.copyWith(
                                    color: ThemeClass.backgroundColorDark,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize),
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0)),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey
                                  //         .withOpacity(0.2), // Light shadow color
                                  //     spreadRadius: 2,
                                  //     blurRadius: 8,
                                  //     offset: const Offset(
                                  //         0, 4), // Changes the shadow position
                                  //   ),
                                  // ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            BodyText1(text: "Tracking ID"),
                                            DescriptionText(
                                                descriptionText: "#453335644"),
                                            SizedBox(
                                              height: kHeight,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      width:
                                                          10.0, // Set the width of the circle
                                                      height:
                                                          10.0, // Set the height of the circle (should be the same as width for a perfect circle)
                                                      decoration: BoxDecoration(
                                                        color: Colors.green[
                                                            600], // Set the color of the circle
                                                        shape: BoxShape
                                                            .circle, // Ensure the container is shaped like a circle
                                                      ),
                                                    ),
                                                    DottedVerticalDivider(
                                                      height: 50,
                                                      width: 1,
                                                      color: Colors.grey,
                                                      dotRadius: 1,
                                                      spacing: 5,
                                                    ),
                                                    Icon(
                                                      Icons.pin_drop,
                                                      color: Colors.red[600],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    BodyText1(text: "From"),
                                                    DescriptionText(
                                                        descriptionText:
                                                            "Vaibhav Nagar, Belgaum"),
                                                    BodyText1(
                                                        text: "Sender Shaheed"),
                                                    SizedBox(
                                                      height: kHeight,
                                                    ),
                                                    BodyText1(text: "To"),
                                                    DescriptionText(
                                                        descriptionText:
                                                            "Koramangala, Bengaluru"),
                                                    BodyText1(
                                                        text:
                                                            "Reciever Sattappa"),
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: kHeight,
                                            ),
                                            BodyText1(text: "Status"),
                                            DescriptionText(
                                                descriptionText: "On Delivery"),
                                          ],
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          SizedBox(
                                            width: 140,
                                            height: 200,
                                            child: GoogleMap(
                                              padding: EdgeInsets.only(
                                                  bottom: bottomPaddingOfMap),
                                              mapType: MapType.normal,
                                              myLocationEnabled: true,
                                              zoomGesturesEnabled: true,
                                              zoomControlsEnabled: true,
                                              initialCameraPosition:
                                                  _kGooglePlex,
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                if (!_isMapControllerSet) {
                                                  _controllerGoogleMap
                                                      .complete(controller);
                                                  newGoogleMapController =
                                                      controller;
                                                  _isMapControllerSet = true;

                                                  // For Black Theme Google Map
                                                  // blackThemeController();

                                                  setState(() {
                                                    bottomPaddingOfMap = 0.0;
                                                  });
                                                  // Get Users Current Location
                                                  locateUserPosition();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: kHeight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
