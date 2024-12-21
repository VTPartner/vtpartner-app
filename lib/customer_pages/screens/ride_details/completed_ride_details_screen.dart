import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/animation/fade_animation.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/completed_order_model.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/global_filled_button.dart';
import 'package:vt_partner/widgets/global_outlines_button.dart';
import 'package:vt_partner/widgets/shimmer_card.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'dart:async';
import 'package:vt_partner/global/global.dart' as glb;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../utils/app_styles.dart';

class CustomerCompletedRideDetailsScreen extends StatefulWidget {
  const CustomerCompletedRideDetailsScreen({super.key});

  @override
  State<CustomerCompletedRideDetailsScreen> createState() =>
      _CustomerCompletedRideDetailsScreenState();
}

class _CustomerCompletedRideDetailsScreenState
    extends State<CustomerCompletedRideDetailsScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  CompletedOrderModel completedOrderModel = CompletedOrderModel();

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

BitmapDescriptor? iconAnimatedMarker;
  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

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
bool isLoading = true;

  Future<void> getOrderDetails() async {
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();

    //booking_details_live_track
    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_order_details',
          {'order_id': glb.order_id});
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        var result = response['results'][0];
        var customer_name = result['customer_name'].toString();
        var customer_id = result['customer_id'].toString();
        var pickup_address = result['pickup_address'].toString();
        var drop_address = result['drop_address'].toString();

        var driverName = result['driver_first_name'].toString();
        var driverMobileNo = result['driver_mobile_no'].toString();
        var bookingTiming = result['booking_timing'].toString();
        var paymentMethod = result['payment_method'].toString();
        var bookingStatus = result['booking_status'].toString();
        var senderName = result['sender_name'].toString();
        var senderNumber = result['sender_number'].toString();
        var receiverName = result['receiver_name'].toString();
        var receiverNumber = result['receiver_number'].toString();
        var vehicleName = result['vehicle_name'].toString();
        var vehiclePlateNo = result['vehicle_plate_no'].toString();
        var vehicleFuelType = result['vehicle_fuel_type'].toString();
        var driverProfilePic = result['profile_pic'].toString();
        var totalPrice = result['total_price'].toString();
        var otp = result['otp'].toString();
        var driver_id = result['driver_id'].toString();
        var vehicle_image = result['vehicle_image'].toString();

        var distance = result['distance'].toString();
        var pickup_lat = double.parse(result['pickup_lat'].toString());
        var pickup_lng = double.parse(result['pickup_lng'].toString());
        var destination_lat =
            double.parse(result['destination_lat'].toString());
        var destination_lng =
            double.parse(result['destination_lng'].toString());
        var ratings = result['ratings'].toString();

        completedOrderModel.pickupLatLng = LatLng(pickup_lat, pickup_lng);
        completedOrderModel.dropLatLng =
            LatLng(destination_lat, destination_lng);
        completedOrderModel.customerName = customer_name;
        completedOrderModel.customerId = customer_id;
        completedOrderModel.totalDistance = distance;
        completedOrderModel.pickupAddress = pickup_address;
        completedOrderModel.dropAddress = drop_address;
        completedOrderModel.ratings = ratings;
        completedOrderModel.driverName = driverName;
        completedOrderModel.driverMobileNo = driverMobileNo;
        completedOrderModel.bookingTiming =
            glb.formatEpochToDateTime(double.parse(bookingTiming));
        completedOrderModel.paymentMethod = paymentMethod;
        completedOrderModel.bookingStatus = bookingStatus;
        completedOrderModel.senderName = senderName;
        completedOrderModel.senderNumber = senderNumber;
        completedOrderModel.receiverName = receiverName;
        completedOrderModel.receiverNumber = receiverNumber;
        completedOrderModel.vehicleName = vehicleName;
        completedOrderModel.totalPrice = totalPrice;
        completedOrderModel.otp = otp;
        completedOrderModel.driverId = driver_id;
        completedOrderModel.vehicleImage = vehicle_image;
        completedOrderModel.pickupLat = pickup_lat;
        completedOrderModel.pickupLng = pickup_lng;
        completedOrderModel.dropLat = destination_lat;
        completedOrderModel.dropLng = destination_lng;

        completedOrderModel.vehiclePlateNo = vehiclePlateNo;
        completedOrderModel.vehicleFuelType = vehicleFuelType;
        completedOrderModel.driverImage = driverProfilePic;
        completedOrderModel.orderId = glb.order_id;
        isLoading = false;
        drawPolyLineFromOriginToDestination(
            completedOrderModel.pickupLatLng!, completedOrderModel.dropLatLng!);
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Order Details Found");

        Navigator.pop(context);
      } else {
        //glb.showToast("An error occurred while fetching booking details");
        // glb.showToast("An error occurred while fetching booking details: ${e.toString()}");
      }
    } finally {
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  var ratings = 0.0;
  var ratings_description = 'NA';

  Future<void> saveRatings() async {
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();

    //booking_details_live_track
    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/save_order_ratings', {
        'order_id': glb.order_id,
        'ratings': ratings,
        'ratings_description': ratings_description
      });
      if (kDebugMode) {
        print(response);
      }
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(
      LatLng pickupLatLng, LatLng dropLatLng) async {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CircularProgressIndicator(),
    // );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            pickupLatLng, dropLatLng);

    //Navigator.pop(context);

    //print("These are points = ");
    //print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
          color: ThemeClass.facebookBlue,
          polylineId: const PolylineId("PolylineID"),
          jointType: JointType.round,
          points: polyLinePositionCoordinates,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          width: 3);

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (pickupLatLng.latitude > dropLatLng.latitude &&
        pickupLatLng.longitude > dropLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: dropLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > dropLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickupLatLng.latitude, dropLatLng.longitude),
        northeast: LatLng(dropLatLng.latitude, pickupLatLng.longitude),
      );
    } else if (pickupLatLng.latitude > dropLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(dropLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, dropLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: pickupLatLng, northeast: dropLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: dropLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: pickupLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: dropLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _generateInvoicePDF() async {
    Future<Uint8List> loadAssetImage(String assetPath) async {
      return await rootBundle
          .load(assetPath)
          .then((data) => data.buffer.asUint8List());
    }

    // Capture the map screenshot
    Uint8List screenshotBytes = await _screenshotController.capture() ??
        (throw Exception("Failed to capture map screenshot"));

    // Create the PDF
    final pdf = pw.Document();

    // Add the screenshot
    final mapImage = pw.MemoryImage(screenshotBytes);
    final imageBytes = await loadAssetImage('assets/images/logo_new.png');
    final greenDotBytes = await loadAssetImage('assets/icons/green_dot.png');
    final redDotBytes = await loadAssetImage('assets/icons/red_dot.png');
    final titilliumWebFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/TitilliumWeb-Regular.ttf'));

    final logo = pw.MemoryImage(imageBytes);
    final redDot = pw.MemoryImage(redDotBytes);
    final greenDot = pw.MemoryImage(greenDotBytes);
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // pw.Image(mapImage, height: 200, fit: pw.BoxFit.cover),
            // pw.SizedBox(height: 20),

            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Invoice / Consignment Note",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          font: titilliumWebFont,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(children: [
                          pw.Image(logo, height: 100, width: 100),
                        ]),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                  "Invoice No : ${completedOrderModel.orderId}"),
                              pw.Text(
                                  "Date & Time : ${completedOrderModel.bookingTiming}"),
                            ]),
                      ]),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex("#F9F9F9"),
                              ),
                              child: pw.Padding(
                                padding: pw.EdgeInsets.all(4.0),
                                child: pw.Column(
                                  children: [
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(4.0),
                                      child: pw.Row(
                                        children: [
                                          pw.Text(
                                            "CUSTOMER NAME : ${completedOrderModel.customerName!.toUpperCase()}",
                                            style: pw.TextStyle(
                                              fontSize: 10.0,
                                              font: titilliumWebFont,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(4.0),
                                      child: pw.Row(
                                        children: [
                                          pw.Text(
                                            "DRIVER NAME : ${completedOrderModel.driverName!.toUpperCase()}",
                                            style: pw.TextStyle(
                                              fontSize: 10.0,
                                              font: titilliumWebFont,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Container(
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex("#EEF2FF"),
                                borderRadius: pw.BorderRadius.circular(6.0),
                              ),
                              child: pw.Padding(
                                padding: pw.EdgeInsets.all(4.0),
                                child: pw.Text(
                                  "${completedOrderModel.vehicleName}  |  ${completedOrderModel.vehiclePlateNo}",
                                  style: pw.TextStyle(
                                    fontSize: 10.0,
                                    font: titilliumWebFont,
                                    color: PdfColor.fromHex("#0046DA"),
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            // Pickup Address
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(top: 4.0),
                                  child:
                                      pw.Image(greenDot, height: 10, width: 10),
                                ),
                                pw.SizedBox(width: 4.0),
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Pickup Address",
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                        font: titilliumWebFont,
                                      ),
                                    ),
                                    pw.Container(
                                      width: 220,
                                      child: pw.Text(
                                        "${completedOrderModel.pickupAddress}",
                                        style: pw.TextStyle(
                                          fontSize: 12.0,
                                          font: titilliumWebFont,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 20),
                            // Drop Address
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(top: 4.0),
                                  child:
                                      pw.Image(redDot, height: 10, width: 10),
                                ),
                                pw.SizedBox(width: 4.0),
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Drop Address",
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                        font: titilliumWebFont,
                                      ),
                                    ),
                                    pw.Container(
                                      width: 220,
                                      child: pw.Text(
                                        "${completedOrderModel.dropAddress}",
                                        style: pw.TextStyle(
                                          fontSize: 12.0,
                                          font: titilliumWebFont,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(width: 20), // Space between the containers

                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex("#F9F9F9"),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.SizedBox(height: 10),
                                pw.Text(
                                  "PAYMENT DETAILS",
                                  style: pw.TextStyle(
                                    fontSize: 16.0,
                                    font: titilliumWebFont,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Divider(
                                  color: PdfColor.fromHex("#F0F0F0"),
                                  thickness: 1,
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "Ride Fare",
                                          style: const pw.TextStyle(
                                            fontSize: 10.0,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                        pw.Text(
                                          "Rs. ${completedOrderModel.totalPrice}/-",
                                          style: pw.TextStyle(
                                            fontSize: 10.0,
                                            font: titilliumWebFont,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                      ]),
                                ),
                                pw.Divider(
                                  color: PdfColor.fromHex("#F0F0F0"),
                                  thickness: 1,
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "Promo / Discount",
                                          style: const pw.TextStyle(
                                            fontSize: 10.0,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                        pw.Text(
                                          "Rs. 0.0/-",
                                          style: pw.TextStyle(
                                            fontSize: 10.0,
                                            font: titilliumWebFont,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                      ]),
                                ),
                                pw.Divider(
                                  color: PdfColor.fromHex("#F0F0F0"),
                                  thickness: 1,
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "CGST TAX",
                                          style: const pw.TextStyle(
                                            fontSize: 10.0,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                        pw.Text(
                                          "Rs. 0.0/-",
                                          style: pw.TextStyle(
                                            fontSize: 10.0,
                                            font: titilliumWebFont,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                      ]),
                                ),
                                pw.Divider(
                                  color: PdfColor.fromHex("#F0F0F0"),
                                  thickness: 1,
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "SGST Tax",
                                          style: const pw.TextStyle(
                                            fontSize: 10.0,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                        pw.Text(
                                          "Rs. 0.0/-",
                                          style: pw.TextStyle(
                                            fontSize: 10.0,
                                            font: titilliumWebFont,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                      ]),
                                ),
                                pw.Divider(
                                  color: PdfColor.fromHex("#F0F0F0"),
                                  thickness: 1,
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "Time Penalty",
                                          style: const pw.TextStyle(
                                            fontSize: 10.0,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                        pw.Text(
                                          "Rs. 0.0/-",
                                          style: pw.TextStyle(
                                            fontSize: 10.0,
                                            font: titilliumWebFont,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                      ]),
                                ),
                                pw.Divider(
                                  color: PdfColor.fromHex("#F0F0F0"),
                                  thickness: 1,
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "Payment via",
                                          style: const pw.TextStyle(
                                            fontSize: 10.0,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                        pw.Text(
                                          "${completedOrderModel.paymentMethod}",
                                          style: const pw.TextStyle(
                                            fontSize: 10.0,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                      ]),
                                ),
                                pw.Divider(
                                  color: PdfColor.fromHex("#F0F0F0"),
                                  thickness: 1,
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2.0),
                                  child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          "Total Amount",
                                          style: pw.TextStyle(
                                            fontSize: 16.0,
                                            font: titilliumWebFont,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                        pw.Text(
                                          "Rs. ${completedOrderModel.totalPrice}/-",
                                          style: pw.TextStyle(
                                            fontSize: 10.0,
                                            font: titilliumWebFont,
                                          ),
                                          overflow: pw.TextOverflow.visible,
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Padding(
                      padding: pw.EdgeInsets.all(4.0),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "DECLARATION : ",
                              style: pw.TextStyle(
                                  fontSize: 14.0,
                                  color: PdfColor.fromHex("#828282"),
                                  font: titilliumWebFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "1. Nature of Service: VT Partner is a transport service platform that connects customers with independent drivers for goods delivery services. We act solely as an intermediary and do not own, operate, or control any vehicles or drivers.",
                              style: pw.TextStyle(
                                fontSize: 8.0,
                                color: PdfColor.fromHex("#828282"),
                                font: titilliumWebFont,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "2. Liability: While we strive to connect you with reliable drivers, VT Partner does not assume responsibility for the quality, condition, or timely delivery of goods by the drivers.",
                              style: pw.TextStyle(
                                fontSize: 8.0,
                                color: PdfColor.fromHex("#828282"),
                                font: titilliumWebFont,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "3. Contractual Relationship: When booking a delivery service, the contract is between the customer and the driver. VT Partner facilitates this connection but is not a party to the contract.",
                              style: pw.TextStyle(
                                fontSize: 8.0,
                                color: PdfColor.fromHex("#828282"),
                                font: titilliumWebFont,
                              ),
                            ),
                          ])),
                  pw.SizedBox(height: 20),
                  pw.Padding(
                      padding: pw.EdgeInsets.all(4.0),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "VT Partner Trans Private Limited",
                              style: pw.TextStyle(
                                  fontSize: 12.0,
                                  font: titilliumWebFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Plot No.pap-a-45, Chakan, Midc Ph-iv, Nighoje, Khed, Nighoje Khed Pune, Maharashtra 410501 India",
                              style: pw.TextStyle(
                                fontSize: 8.0,
                                color: PdfColor.fromHex("#828282"),
                                font: titilliumWebFont,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                          ])),
                ]),

            // pw.Text("Customer Name: ${orderModel.customerName}"),
            // pw.Text("Driver Name: ${orderModel.driverName}"),
            // pw.Text("Pickup Address: ${orderModel.pickupAddress}"),
            // pw.Text("Drop Address: ${orderModel.dropAddress}"),
            // pw.Text("Booking Date: ${orderModel.bookingDate}"),
            // pw.Text("Payment Method: ${orderModel.paymentMethod}"),
            // pw.Text("Total Price: ${orderModel.totalPrice}"),
            // pw.Text("Distance: ${orderModel.distance}"),
            // pw.Text("Vehicle: ${orderModel.vehicle}"),
            // pw.Text("OTP: ${orderModel.otp}"),
          ],
        ),
      ),
    );

    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    // final filePath =
    //     "${directory.path}/invoice-${DateTime.now().millisecondsSinceEpoch}.pdf";
    final filePath =
        "${directory.path}/invoice-${completedOrderModel.orderId}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Share the PDF
    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "Invoice-CRN-${completedOrderModel.orderId}.pdf");
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();

    getOrderDetails();

  }



  double searchLocationContainerHeight = 220.0;
  var _showReceipt = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemeClass.backgroundColorLightPink,
      body: isLoading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.1),
                  enabled: isLoading,
                  child: const VTPartnerLoader(),
                ),
              ],
            )
          : SafeArea(
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
                                "CRN ${glb.order_id}",
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
                          color: Colors.green[900]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Completed',
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
                          child: Screenshot(
                            controller: _screenshotController,
                            child: GoogleMap(
                              mapType: MapType.normal,
                              // myLocationEnabled: true,
                              zoomGesturesEnabled: true,
                              buildingsEnabled: true,
                                    
                              zoomControlsEnabled: false,
                              initialCameraPosition: _kGooglePlex,
                              polylines: setOfPolyline,
                              markers: setOfMarkers,
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
                                              "${completedOrderModel.senderName} - ${completedOrderModel.senderNumber}"),
                                SizedBox(
                                  width: width - 80,
                                  child: BodyText1(
                                            text: completedOrderModel
                                                .pickupAddress!),
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
                                          descriptionText:
                                              "${completedOrderModel.receiverName} - ${completedOrderModel.receiverNumber}"),
                                SizedBox(
                                  width: width - 80,
                                  child: BodyText1(
                                            text: completedOrderModel
                                                .dropAddress!),
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
                    // Container(
                    //   decoration: BoxDecoration(color: Colors.white),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         DescriptionText(descriptionText: "RIDE DETAILS"),
                    //         SizedBox(
                    //           height: 10.0,
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(bottom: 8.0),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "Ride Type",
                    //                 style: nunitoSansStyle.copyWith(
                    //                     color: Colors.grey[800],
                    //                     fontSize: Theme.of(context)
                    //                         .textTheme
                    //                         .bodySmall
                    //                         ?.fontSize),
                    //                 overflow: TextOverflow.visible,
                    //               ),
                    //               DescriptionText(descriptionText: "Local"),
                    //             ],
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(bottom: 8.0),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "Driver Name",
                    //                 style: nunitoSansStyle.copyWith(
                    //                     color: Colors.grey[800],
                    //                     fontSize: Theme.of(context)
                    //                         .textTheme
                    //                         .bodySmall
                    //                         ?.fontSize),
                    //                 overflow: TextOverflow.visible,
                    //               ),
                    //               DescriptionText(descriptionText: "DattaRaj Patil"),
                    //             ],
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(bottom: 8.0),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "Vehicle",
                    //                 style: nunitoSansStyle.copyWith(
                    //                     color: Colors.grey[800],
                    //                     fontSize: Theme.of(context)
                    //                         .textTheme
                    //                         .bodySmall
                    //                         ?.fontSize),
                    //                 overflow: TextOverflow.visible,
                    //               ),
                    //               DescriptionText(descriptionText: "Tata Ace"),
                    //             ],
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(bottom: 8.0),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "Date & Time",
                    //                 style: nunitoSansStyle.copyWith(
                    //                     color: Colors.grey[800],
                    //                     fontSize: Theme.of(context)
                    //                         .textTheme
                    //                         .bodySmall
                    //                         ?.fontSize),
                    //                 overflow: TextOverflow.visible,
                    //               ),
                    //               DescriptionText(
                    //                   descriptionText: "20/12/2024, 10:34 PM"),
                    //             ],
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(bottom: 8.0),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "Booked For",
                    //                 style: nunitoSansStyle.copyWith(
                    //                     color: Colors.grey[800],
                    //                     fontSize: Theme.of(context)
                    //                         .textTheme
                    //                         .bodySmall
                    //                         ?.fontSize),
                    //                 overflow: TextOverflow.visible,
                    //               ),
                    //               DescriptionText(descriptionText: "Goods Delivery"),
                    //             ],
                    //           ),
                    //         ),
                    //         Divider(
                    //           color: Colors.grey,
                    //           thickness: 0.1,
                    //         ),
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: [
                    //             Center(
                    //               child: InkWell(
                    //                 onTap: () {
                    //                   setState(() {
                    //                     _showReceipt = !_showReceipt;
                    //                   });
                    //                 },
                    //                 child: Text(
                    //                   _showReceipt
                    //                       ? "Hide Fare Breakdown"
                    //                       : "View Fare Breakdown",
                    //                   style: nunitoSansStyle.copyWith(
                    //                       color: _showReceipt
                    //                           ? Colors.red
                    //                           : ThemeClass.facebookBlue,
                    //                       fontWeight: FontWeight.bold,
                    //                       fontSize: Theme.of(context)
                    //                           .textTheme
                    //                           .bodyMedium
                    //                           ?.fontSize),
                    //                   overflow: TextOverflow.visible,
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10.0,
                    // ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                        child: Column(
                    children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child: Image.network(
                                      "${completedOrderModel.driverImage}",
                                      fit: BoxFit.cover,
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DescriptionText(
                                        descriptionText:
                                            "${completedOrderModel.driverName}"),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SubTitleText(
                                            subTitle:
                                                "${completedOrderModel.vehicleName}"),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        SubTitleText(
                                            subTitle:
                                                " | ${completedOrderModel.vehiclePlateNo}"),
                                        SubTitleText(
                                            subTitle:
                                                " | ${completedOrderModel.vehicleFuelType}"),
                                      ],
                                    ),
                                          
                                    SubTitleText(
                                        subTitle:
                                            "${completedOrderModel.bookingTiming}"),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
                    SizedBox(
                      height: kHeight,
                    ),
                    FadeAnimation(
                      delay: 0.5,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DescriptionText(
                                  descriptionText: "PAYMENT DETAILS"),
                              SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    DescriptionText(
                                        descriptionText:
                                            " ₹ ${completedOrderModel.totalPrice!}"),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      "₹ ${double.parse(completedOrderModel.totalPrice!).round()}",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/icons/cash.png",
                                          width: 20,
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        DescriptionText(
                                            descriptionText:
                                                '${completedOrderModel.paymentMethod!}'),
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
                    //     completedOrderModel.ratings == "0.0"
                    //         ? Container(
                    // padding:
                    //     const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    // child: Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Material(
                    //       color: Colors.transparent,
                    //       child: InkWell(
                    //                     onTap: () {
                    //                       glb.driverImage =
                    //                           completedOrderModel.driverImage!;
                    //                       glb.driverName =
                    //                           completedOrderModel.driverName!;
                    //                       //_showRatingBottomSheet(context);
                    //                       Navigator.pushNamed(context,
                    //                           GoodsDriverRatingScreenRoute);
                    //                     },
                    //         borderRadius: BorderRadius.circular(8.0),
                    //         child: Ink(
                    //           padding: const EdgeInsets.symmetric(
                    //               horizontal: 36.0, vertical: 12.0),
                    //           decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(6.0),
                    //             color:
                    //                 Colors.yellow[900], // Button background color
                    //           ),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Image.asset(
                    //                 "assets/icons/star.png",
                    //                 width: 20,
                    //                 height: 20,
                    //               ),
                    //               SizedBox(
                    //                 width: 5.0,
                    //               ),
                    //               Text(
                    //                 'Rate your ride',
                    //                 style: robotoStyle.copyWith(
                    //                   fontWeight: FontWeight.w700,
                    //                   color: Colors.white, // Text color
                    //                   fontSize: 14.0,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //           )
                    //         : SizedBox(),
              SizedBox(
                height: kHeight * 10,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                completedOrderModel.ratings == "0.0"
                    ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                          onTap: () {
                            glb.driverImage = completedOrderModel.driverImage!;
                            glb.driverName = completedOrderModel.driverName!;
                            //_showRatingBottomSheet(context);
                            Navigator.pushNamed(
                                context, GoodsDriverRatingScreenRoute);
                          },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color:
                            ThemeClass.facebookBlue, // Button background color
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                                  Icons.star,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                                  'Rate Ride',
                            style: robotoStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white, // Text color
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                      )
                    : SizedBox(),
                SizedBox(
                  width: kHeight,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _generateInvoicePDF();
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: Colors.yellow[900], // Button background color
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/icons/receipt.png",
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Invoice ',
                            style: robotoStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white, // Text color
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingBottomSheet(BuildContext context) {
    double rating = 0.0;
    TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.7,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Rate Your Ride",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RatingBar.builder(
                          initialRating: 1,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 40.0,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (value) {
                            rating = value;
                            setState(() {
                              ratings = rating;
                            });
                            print("rating::$rating");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // TextField(
                    //   controller: reviewController,
                    //   maxLines: 4,
                    //   decoration: InputDecoration(
                    //     labelText: 'Write a review (optional)',
                    //     labelStyle: const TextStyle(color: Colors.grey),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //       borderSide: const BorderSide(
                    //         color: Colors.amber,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        // Handle the submission of the rating and review
                        print("Rating: $rating");
                        print("Review: ${reviewController.text}");

                        // setState(() {
                        //   ratings_description = reviewController.text;
                        // });
                        saveRatings();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          "Submit",
                          style: nunitoSansStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
