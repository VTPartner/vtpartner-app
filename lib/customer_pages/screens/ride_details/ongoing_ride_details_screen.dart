import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vt_partner/animation/fade_animation.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'dart:async';

import '../../../utils/app_styles.dart';

class CustomerOngoingRideDetailsScreen extends StatefulWidget {
  const CustomerOngoingRideDetailsScreen({super.key});

  @override
  State<CustomerOngoingRideDetailsScreen> createState() =>
      _CustomerOngoingRideDetailsScreenState();
}

class _CustomerOngoingRideDetailsScreenState extends State<CustomerOngoingRideDetailsScreen> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  double searchLocationContainerHeight = 220.0;
  var _showReceipt = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemeClass.backgroundColorLightPink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.grey[900],
                            )),
                        Text(
                          "CRN 7895556696",
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.fontSize),
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 6.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26.0),
                          color: ThemeClass.facebookBlue),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ongoing',
                            style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    width: width,
                    height: height / 3.5,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      buildingsEnabled: true,
                      zoomControlsEnabled: true,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _controllerGoogleMap.complete(controller);
                        newGoogleMapController = controller;

                        //For Black Theme Google Map
                        // blackThemeController();

                        setState(() {
                          bottomPaddingOfMap = 0.0;
                        });
                        //Get Users Current Location
                        locateUserPosition();
                      },
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 8.0,
                  ),
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5.0,
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  "assets/icons/green_dot.png",
                                  width: 20,
                                  height: 20,
                                ),
                                DottedVerticalDivider(
                                  height: 44,
                                  width: 1,
                                  color: Colors.grey,
                                  dotRadius: 1,
                                  spacing: 5,
                                ),
                                Image.asset(
                                  "assets/icons/red_dot.png",
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pickup",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.green[900],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                DescriptionText(
                                    descriptionText:
                                        "Shaheed Maniyar. 8296565587"),
                                SizedBox(
                                  width: width - 80,
                                  child: BodyText1(
                                      text:
                                          "Plot No 83, Gat 765 Industrial Area phase"),
                                ),
                                SizedBox(
                                  height: kHeight,
                                ),
                                Text(
                                  "Destination",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.red,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                DescriptionText(
                                    descriptionText: "Arun Patil - 7654343376"),
                                SizedBox(
                                  width: width - 80,
                                  child: BodyText1(
                                      text:
                                          "Q68R+PJ Ranjangaon, Ashtavinayak Mahamarg, Malthan Rd, Ranjangaon, Maharashtra 412209"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DescriptionText(descriptionText: "RIDE DETAILS"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ride Type",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.grey[800],
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                            DescriptionText(descriptionText: "Local"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Driver Name",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.grey[800],
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                            DescriptionText(descriptionText: "DattaRaj Patil"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Vehicle",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.grey[800],
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                            DescriptionText(descriptionText: "Tata Ace"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Date & Time",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.grey[800],
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                            DescriptionText(
                                descriptionText: "20/12/2024, 10:34 PM"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Booked For",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.grey[800],
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                            DescriptionText(descriptionText: "Goods Delivery"),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.1,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showReceipt = !_showReceipt;
                                });
                              },
                              child: Text(
                                _showReceipt
                                    ? "Hide Fare Breakdown"
                                    : "View Fare Breakdown",
                                style: nunitoSansStyle.copyWith(
                                    color: _showReceipt
                                        ? Colors.red
                                        : ThemeClass.facebookBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.fontSize),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Visibility(
                visible: _showReceipt,
                child: FadeAnimation(
                  delay: 0.5,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DescriptionText(descriptionText: "PAYMENT DETAILS"),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ride Fare",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey[800],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                DescriptionText(descriptionText: " ₹ 519.0"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Promo / Discount",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey[800],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                DescriptionText(descriptionText: "₹ 0.0"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "CGST Tax",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey[800],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                DescriptionText(descriptionText: "₹ 0.0"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "SGST Tax",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey[800],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                DescriptionText(descriptionText: "₹ 0.0"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Time Penalty",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey[800],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                DescriptionText(descriptionText: "₹ 0.0"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                Text(
                                  "₹ 519.0",
                                  style: nunitoSansStyle.copyWith(
                                      color: ThemeClass.facebookBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 0.1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Payment Via",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey[800],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/icons/amazon.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: 2.0,
                                    ),
                                    DescriptionText(
                                        descriptionText: 'Amazon Pay'),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Handle tap
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors
                                .transparent, // Make the button transparent
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              // Add an outline
                              color: Colors.red, // Outline color
                              width: 2.0, // Outline width
                            ),
                          ),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Cancel Booking',
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .red, // Text color matches outline color
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.fontSize),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                      height: 15.0,
                    ),
                  Text(
                      "Please note that if the driver has arrived or has traveled halfway to your location, delivery charges will apply based on the distance covered.",
                      style: nunitoSansStyle.copyWith(
                          color: Colors.grey[800], fontSize: 11.5),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}
