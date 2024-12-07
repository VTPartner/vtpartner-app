import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

class BookingSearchDriverScreen extends StatefulWidget {
  const BookingSearchDriverScreen({super.key});

  @override
  State<BookingSearchDriverScreen> createState() =>
      _BookingSearchDriverScreenState();
}

class _BookingSearchDriverScreenState extends State<BookingSearchDriverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

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
    if (newGoogleMapController != null) {
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};
  String? bookingId;
  String totalAmount = "0.0";

// Ensure to load polylines only after the GoogleMapController is ready
  loadPolyLines() async {
    final pref = await SharedPreferences.getInstance();
    bookingId = pref.getString("booking_id");
    //totalAmount = pref.getString("total_amount");
    // Now that the controller is ready, draw the polyline
    await drawPolyLineFromOriginToDestination();
  }

  bool _showRetryMessage = false;
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPolyLines();
    _startRetryMessageTimer();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(); // Repeat the animation

    _dotCount = IntTween(begin: 1, end: 3).animate(_controller);
  }

  void _startRetryMessageTimer() {
    _timer = Timer(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _showRetryMessage = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller
    _timer.cancel(); // Cancel the timer if the screen is disposed
    super.dispose();
  }

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeadingText(title: 'Trip CRN ${bookingId!}'),
                            SubTitleText(subTitle: 'Booking confirmed'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ClipRRect(
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
                            circles: circlesSet,
                            onMapCreated:
                                (GoogleMapController controller) async {
                              _controllerGoogleMap.complete(controller);
                              newGoogleMapController = controller;
                              

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/ware_house.png",
                        width: 100,
                        height: 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Booking Done",
                            style: nunitoSansStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 12.0),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Waiting for the driver to confirm your booking",
                        style: nunitoSansStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16.0),
                      ),
                      AnimatedBuilder(
                        animation: _dotCount,
                        builder: (context, child) {
                          String dots = "." * _dotCount.value;
                          return Text(
                            "$dots",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      if (_showRetryMessage)
                        Text(
                          "If Driver not found please retry again later.",
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 12.0),
                        ),
                    ],
                  )
                ],
              ),
        bottomSheet: Visibility(
          visible: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: ThemeClass.facebookBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                "assets/icons/cash.png",
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cash",
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Visibility(
                        visible: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, BookingSuccessScreenRoute);
                              },
                              child: Text(
                                "Rs. ${totalAmount}/-",
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
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
          width: 3
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
    if (newGoogleMapController != null) {
    Future.delayed(const Duration(milliseconds: 1000), () {
        newGoogleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
            boundsLatLng, 50), // Customize as per your bounds.
      );
    });
    }
  }

}
