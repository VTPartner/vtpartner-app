import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
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
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/global/global.dart' as glb;

class CabPickupToDropLocationConfirmScreen extends StatefulWidget {
  const CabPickupToDropLocationConfirmScreen({super.key});

  @override
  State<CabPickupToDropLocationConfirmScreen> createState() =>
      _CabPickupToDropLocationConfirmScreenState();
}

class _CabPickupToDropLocationConfirmScreenState
    extends State<CabPickupToDropLocationConfirmScreen> {
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        HeadingText(title: 'Location Navigation'),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
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
                                    SizedBox(
                                      width: width -
                                          80, // Takes the full width of the parent
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Pickup Location",
                                            style: nunitoSansStyle.copyWith(
                                                color: Colors.green[900],
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.fontSize),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                    height5Space,
                                    SizedBox(
                                      width: width - 80,
                                      child: BodyText1(
                                          text: Provider.of<AppInfo>(context)
                                                      .userPickupLocation !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .userPickupLocation!
                                                  .locationName!
                                              : Provider.of<AppInfo>(context)
                                                          .userCurrentLocation !=
                                                      null
                                                  ? Provider.of<AppInfo>(
                                                          context)
                                                      .userCurrentLocation!
                                                      .locationName!
                                                  : "Error Loading Your Location"),
                                    ),
                                    SizedBox(
                                      height: kHeight,
                                    ),
                                    SizedBox(
                                      width: width -
                                          80, // Takes the full width of the parent
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "DropOff Location",
                                            style: nunitoSansStyle.copyWith(
                                                color: Colors.green[900],
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.fontSize),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                    height5Space,
                                    SizedBox(
                                      width: width - 80,
                                      child: BodyText1(
                                          text: Provider.of<AppInfo>(context)
                                                      .userDropOfLocation !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .userDropOfLocation!
                                                  .locationName!
                                              : "Please Select Destination before you proceed"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: kHeight,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Visibility(
                                //   visible: false,
                                //   child: InkWell(
                                //     onTap: () {
                                //       Navigator.pushNamed(
                                //           context, AddStopsRoute);
                                //     },
                                //     child: Padding(
                                //       padding: const EdgeInsets.only(top: 12.0),
                                //       child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //           Icon(
                                //             Icons.add_circle_outline,
                                //             size: 18,
                                //           ),
                                //           SizedBox(
                                //             width: 5.0,
                                //           ),
                                //           DescriptionText(
                                //               descriptionText: 'ADD STOPS')
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        DescriptionText(
                                            descriptionText: 'Edit Locations')
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: kHeight),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26.0),
                        child: Stack(children: [
                          SizedBox(
                            height: height - 450,
                            child: GoogleMap(
                              mapType: MapType.normal,
                              myLocationEnabled: true,
                              zoomGesturesEnabled: true,
                              zoomControlsEnabled: true,
                              initialCameraPosition: _kGooglePlex,
                              polylines: polyLineSet,
                              markers: markersSet,
                              // circles: circlesSet,
                              onMapCreated:
                                  (GoogleMapController controller) async {
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
                        ]),
                      ),
                    ),
                  )
                ],
              ),
        bottomSheet: isLoading
            ? null
            : Container(
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
                          // Navigator.pushNamed(context, SelectVehiclesRoute);
                          glb.showSnackBar(context,
                              "Unfortunately, there are no available cab drivers near your pickup location at the moment.");
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                                image:
                                    AssetImage("assets/images/buttton_bg.png"),
                                fit: BoxFit.fill),
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
                                      'Select Online Driver',
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
              ));
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
          width: 3);

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
