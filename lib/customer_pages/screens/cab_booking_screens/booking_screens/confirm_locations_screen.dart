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

class CabConfirmLocationsScreen extends StatefulWidget {
  const CabConfirmLocationsScreen({super.key});

  @override
  State<CabConfirmLocationsScreen> createState() =>
      _CabConfirmLocationsScreenState();
}

class _CabConfirmLocationsScreenState extends State<CabConfirmLocationsScreen> {
  var isLoading = false;
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;
//15.892953, 74.518013
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
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
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

// Ensure to load polylines only after the GoogleMapController is ready
  loadPolyLines() async {
    // Now that the controller is ready, draw the polyline
    await drawPolyLineFromOriginToDestination();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPolyLines();
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0)),
                      child: SizedBox(
                        height: height - 650,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          zoomGesturesEnabled: true,
                          zoomControlsEnabled: true,
                          initialCameraPosition: _kGooglePlex,
                          polylines: polyLineSet,
                          markers: markersSet,
                          circles: circlesSet,
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, CabPickupLocationSearchRoute);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset(
                                  "assets/icons/green_dot.png",
                                  width: 10,
                                  height: 10,
                                ),
                                SizedBox(
                                  width: width - 80,
                                  child: Text(
                                    Provider.of<AppInfo>(context)
                                                .userPickupLocation !=
                                            null
                                        ? Provider.of<AppInfo>(context)
                                            .userPickupLocation!
                                            .locationName!
                                        : Provider.of<AppInfo>(context)
                                                    .userCurrentLocation !=
                                                null
                                            ? Provider.of<AppInfo>(context)
                                                .userCurrentLocation!
                                                .locationName!
                                            : "Error Loading Your Location",
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.black, fontSize: 12.0),
                                    overflow: TextOverflow
                                        .ellipsis, // Adds ellipsis when text overflows
                                    maxLines:
                                        1, // Limits the text to a single line
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 0.3,
                          color: Colors.grey,
                          indent: 35,
                          endIndent: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, CabDestinationLocationSearchRoute);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset(
                                  "assets/icons/red_dot.png",
                                  width: 10,
                                  height: 10,
                                ),
                                SizedBox(
                                  width: width - 80,
                                  child: Text(
                                    Provider.of<AppInfo>(context)
                                                .userDropOfLocation !=
                                            null
                                        ? Provider.of<AppInfo>(context)
                                            .userDropOfLocation!
                                            .locationName!
                                        : "Error Loading Your Location",
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.black, fontSize: 12.0),
                                    overflow: TextOverflow
                                        .ellipsis, // Adds ellipsis when text overflows
                                    maxLines:
                                        1, // Limits the text to a single line
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 0.3,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Recommended for you',
                    style: nunitoSansStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 12.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex =
                                    index; // Set the selected index on tap
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  boxShadow: selectedIndex ==
                                          index // Apply shadow if selected
                                      ? [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 2,
                                            offset: Offset(0,
                                                1), // Changes position of shadow
                                          ),
                                        ]
                                      : [],
                                  borderRadius: BorderRadius.circular(
                                      8), // Apply rounded corners
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  selectedIndex ==
                                                          index // Apply shadow if selected
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 6.0),
                                                          child: Container(
                                                            height: 30,
                                                            width: 30,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .lightGreen,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            8),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            8))),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                  Image.asset(
                                                    'assets/images/ola_cab.png',
                                                    width: selectedIndex ==
                                                            index // Apply shadow if selected
                                                        ? 60
                                                        : 50,
                                                    height: selectedIndex ==
                                                            index // Apply shadow if selected
                                                        ? 60
                                                        : 50,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '14 min',
                                                style: nunitoSansStyle.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                    fontSize: 12.0),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sedan',
                                                style: nunitoSansStyle.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: selectedIndex ==
                                                            index // Apply shadow if selected
                                                        ? 16.0
                                                        : 14.0),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'AC sedans for daily travel!',
                                                style: nunitoSansStyle.copyWith(
                                                    color: Colors.grey,
                                                    fontSize: selectedIndex ==
                                                            index // Apply shadow if selected
                                                        ? 12.0
                                                        : 10.0),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          selectedIndex ==
                                                  index // Apply shadow if selected
                                              ? Icon(
                                                  Icons.info_outline,
                                                  size: 20,
                                                )
                                              : SizedBox(),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '₹668',
                                            style: nunitoSansStyle.copyWith(
                                              fontSize: selectedIndex ==
                                                      index // Apply shadow if selected
                                                  ? 16.0
                                                  : 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })),
                SizedBox(
                  height: kHeight * 3,
                )
              ],
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Divider(
                    color: Colors.grey,
                    thickness: 0.3,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/icons/cash.png",
                              width: 50,
                              height: 25,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Cash',
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Container(
                          width: 0.5,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: Colors.green[700],
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Coupon',
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Container(
                          width: 0.5,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person_3,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Personal',
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, CabSearchingForCabRoute);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage("assets/images/buttton_bg.png"),
                        fit: BoxFit.cover),
                    color: ThemeClass.facebookBlue,
                    borderRadius: BorderRadius.circular(16.0),
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
                              'Book Sedan',
                              style: nunitoSansStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.fontSize,
                              ),
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
          ],
        ),
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    setState(() {
      isLoading = true;
    });
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickupLocation;

    if (originPosition == null) {
      var currentLocation =
          Provider.of<AppInfo>(context, listen: false).userCurrentLocation;
      if (currentLocation != null) {
        Directions directions = Directions();
        directions.locationId = currentLocation.locationId;
        directions.locationName = currentLocation.locationName;
        directions.locationLatitude = currentLocation.locationLatitude;
        directions.locationLongitude = currentLocation.locationLongitude;
        Provider.of<AppInfo>(context, listen: false)
            .updatePickupLocationAddress(directions);
        originPosition =
            Provider.of<AppInfo>(context, listen: false).userPickupLocation;
      }
    }
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOfLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition!.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition!.locationLongitude!);

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    //Decoding Encoded Points
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: ThemeClass.facebookBlue,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    setState(() {
      isLoading = false;
    });

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: ThemeClass.facebookBlue,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      newGoogleMapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
            boundsLatLng, 50), // Customize as per your bounds.
      );
    });
  }
}
