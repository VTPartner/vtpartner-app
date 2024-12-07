import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/delivery_agent_pages/models/user_ride_request_information.dart';
import 'package:vt_partner/global/global.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:url_launcher/url_launcher.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/shimmer_card.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  //Step 1:: when driver accepts the user ride request
  // pickupLatLng = driverCurrent Location
  // dropLatLng = user PickUp Location

  //Step 2:: driver already picked up the user in his/her car
  // pickupLatLng = user PickUp Location => driver current Location
  // dropLatLng = user DropOff Location
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

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

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

    if (mounted) {
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
    }

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

    if (mounted) {
      if (newTripGoogleMapController != null) {
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
      }
    }

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

    if (mounted) {
      setState(() {
        setOfMarkers.add(originMarker);
        setOfMarkers.add(destinationMarker);
      });
    }

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

    if (mounted) {
      setState(() {
        setOfCircle.add(originCircle);
        setOfCircle.add(destinationCircle);
      });
    }
  }

  UserRideRequestInformationModel userRideRequestInformationModel =
      UserRideRequestInformationModel();

  Future<void> getBookingDetails() async {
    print("getBookingdetailsAsync");
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();
    var current_booking_id = pref.getString("current_booking_id_assigned");
    if (current_booking_id == null || current_booking_id.isEmpty) {
      glb.showToast("No Live Ride Found");
      Navigator.pop(context);
      return;
    }
    //booking_details_live_track
    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/booking_details_live_track',
          {'booking_id': current_booking_id});
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        var result = response['results'][0];
        var customer_name = result['customer_name'].toString();
        var booking_id = result['booking_id'].toString();
        var customer_id = result['customer_id'].toString();
        var pickup_address = result['pickup_address'].toString();
        var drop_address = result['drop_address'].toString();
        var distance = result['distance'].toString();
        var total_time = result['total_time'].toString();
        var sender_name = result['sender_name'].toString();
        var sender_number = result['sender_number'].toString();
        var receiver_name = result['receiver_name'].toString();
        var receiver_number = result['receiver_number'].toString();
        var total_price = double.parse(result['total_price'].toString());
        var pickup_lat = double.parse(result['pickup_lat'].toString());
        var pickup_lng = double.parse(result['pickup_lng'].toString());
        var customer_number = result['customer_mobile_no'].toString();
        var booking_status = result['booking_status'].toString();
        var otp = result['otp'].toString();
        var destination_lat =
            double.parse(result['destination_lat'].toString());
        var destination_lng =
            double.parse(result['destination_lng'].toString());
        if (booking_status == "Cancelled") {
          pref.setString("current_booking_id_assigned", "");
          glb.showToast("This Booking has been Cancelled");
          await Future.delayed(Duration(seconds: 3));
          streamSubscriptionDriverLivePosition?.cancel();
          Navigator.pushReplacementNamed(context, AgentHomeScreenRoute);
        }
        setState(() {
          userRideRequestInformationModel.pickupLatLng =
              LatLng(pickup_lat, pickup_lng);
          userRideRequestInformationModel.dropLatLng =
              LatLng(destination_lat, destination_lng);
          userRideRequestInformationModel.customerName = customer_name;
          userRideRequestInformationModel.customerId = customer_id;
          userRideRequestInformationModel.totalDistance = distance;
          userRideRequestInformationModel.pickupAddress = pickup_address;
          userRideRequestInformationModel.dropAddress = drop_address;
          userRideRequestInformationModel.customerNumber = customer_number;
          userRideRequestInformationModel.totalPrice = total_price;
          userRideRequestInformationModel.totalTime = total_time;
          userRideRequestInformationModel.bookingId = booking_id;
          userRideRequestInformationModel.otp = otp;
          userRideRequestInformationModel.pickupLat = pickup_lat;
          userRideRequestInformationModel.pickupLng = pickup_lng;
          userRideRequestInformationModel.dropLat = destination_lat;
          userRideRequestInformationModel.dropLng = destination_lng;
          userRideRequestInformationModel.senderName = sender_name;
          userRideRequestInformationModel.senderNumber = sender_number;
          userRideRequestInformationModel.receiverName = receiver_name;
          userRideRequestInformationModel.receiverNumber = receiver_number;

          currentStatus = booking_status;
        });

        if (booking_status == "Driver Accepted") {
          nextStatus = "Update to Arrived Location";
        } else if (booking_status == "Driver Arrived") {
          nextStatus = "Verify OTP";
        } else if (booking_status == "OTP Verified") {
          nextStatus = "Start Trip";
        } else {
          nextStatus = "End Trip";
        }

        getDriversLocationUpdatesAtRealTime();
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Booking Details Found");
        Navigator.pop(context);
      } else {
        //glb.showToast("An error occurred while fetching booking details");
        // glb.showToast("An error occurred while fetching booking details: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getBookingDetails();
    //saveAssignedDriverDetailsToUserRideRequest();
  }

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/vtp_partner_truck.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  getDriversLocationUpdatesAtRealTime() {
    LatLng? oldLatLng; // Initialize as null for the first location

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      // Only proceed if the location has changed
      if (oldLatLng == null ||
          oldLatLng!.latitude != latLngLiveDriverPosition.latitude ||
          oldLatLng!.longitude != latLngLiveDriverPosition.longitude) {
        // Update oldLatLng to the new location
        oldLatLng = latLngLiveDriverPosition;

        if (mounted) {
          if (newTripGoogleMapController != null) {
            setState(() {
              CameraPosition cameraPosition =
                  CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
              newTripGoogleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
            });
          }
        }

        updateDurationTimeAtRealTime();

        // Updating driver location at real-time in the database
        updateDriversCurrentPosition(onlineDriverCurrentPosition!.latitude,
            onlineDriverCurrentPosition!.longitude);
      }
    });
  }

  // getDriversLocationUpdatesAtRealTime() {
  //   LatLng oldLatLng = LatLng(0, 0);

  //   streamSubscriptionDriverLivePosition =
  //       Geolocator.getPositionStream().listen((Position position) {
  //     driverCurrentPosition = position;
  //     onlineDriverCurrentPosition = position;

  //     LatLng latLngLiveDriverPosition = LatLng(
  //       onlineDriverCurrentPosition!.latitude,
  //       onlineDriverCurrentPosition!.longitude,
  //     );

  //     // Marker animatingMarker = Marker(
  //     //   markerId: const MarkerId("AnimatedMarker"),
  //     //   position: latLngLiveDriverPosition,
  //     //   icon: iconAnimatedMarker!,
  //     //   infoWindow: const InfoWindow(title: "This is your Position"),
  //     // );
  //     if (mounted) {
  //       if (newTripGoogleMapController != null) {
  //         setState(() {
  //           CameraPosition cameraPosition =
  //               CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
  //           newTripGoogleMapController!
  //               .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  //           // setOfMarkers.removeWhere(
  //           //     (element) => element.markerId.value == "AnimatedMarker");
  //           // setOfMarkers.add(animatingMarker);
  //         });
  //       }
  //     }

  //     oldLatLng = latLngLiveDriverPosition;
  //     updateDurationTimeAtRealTime();

  //     //updating driver location at real time in Database
  //     Map driverLatLngDataMap = {
  //       "latitude": onlineDriverCurrentPosition!.latitude.toString(),
  //       "longitude": onlineDriverCurrentPosition!.longitude.toString(),
  //     };
  //     //TODO:Need to update drivers location here in active_driver_tbl
  //     //Future.delayed(const Duration(seconds: 5), () {
  //     updateDriversCurrentPosition(onlineDriverCurrentPosition!.latitude,
  //         onlineDriverCurrentPosition!.longitude);
  //     // MyApp.restartApp(context);
  //     //});

  //     // FirebaseDatabase.instance
  //     //     .ref()
  //     //     .child("All Ride Requests")
  //     //     .child(userRideRequestInformationModel!.rideRequestId!)
  //     //     .child("driverLocation")
  //     //     .set(driverLatLngDataMap);
  //   });
  // }

  updateDriversCurrentPosition(var latitude, var longitude) async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_previous_lat = pref.getDouble("goods_driver_current_lat");
    var goods_driver_previous_lng = pref.getDouble("goods_driver_current_lng");
    var goods_driver_id = pref.getString("goods_driver_id");
    var condition = goods_driver_previous_lat != null &&
        goods_driver_previous_lat == latitude &&
        goods_driver_previous_lng != null &&
        goods_driver_previous_lng == longitude;
    print("condition::$condition");
    //To avoid multiple entries for same lat lng
    if (condition == true) {
      return;
    }

    final data = {
      'goods_driver_id': goods_driver_id,
      'lat': latitude,
      'lng': longitude,
    };

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/update_goods_drivers_current_location', data);
      if (kDebugMode) {
        print(response);
      }
      // print("prev_latitude::$latitude");
      pref.setDouble("goods_driver_current_lat", latitude);
      pref.setDouble("goods_driver_current_lng", longitude);
      // print("prev_longitude::$longitude");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // //glb.showToast("An error occurred: ${e.toString()}");
      // glb.showToast("Something went wrong");
    }
  }

  Razorpay? _razorpay;
  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var pickupLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      ); //Driver current Location

      var dropLatLng;

      if (rideRequestStatus == "accepted") {
        dropLatLng = userRideRequestInformationModel!
            .pickupLatLng; //user PickUp Location
      } else //arrived
      {
        dropLatLng =
            userRideRequestInformationModel!.dropLatLng; //user DropOff Location
      }

      var directionInformation =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              pickupLatLng, dropLatLng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  bool isLoading = false;
  String nextStatus = "", currentStatus = "";
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> _updateStatus(String status,
      {String? otp, String? amount, String? payment_method}) async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    if (currentStatus == "Cancelled") {
      pref.setString("current_booking_id_assigned", "");
      glb.showToast("This Booking has been Cancelled");
      await Future.delayed(Duration(seconds: 3));
      streamSubscriptionDriverLivePosition?.cancel();
      Navigator.pushReplacementNamed(context, AgentHomeScreenRoute);
    }
    print("Updating status to: $status");
    if (otp != null) print("Entered OTP: $otp");
    if (amount != null) print("Entered Amount: $amount");
    try {
      var driver_id = pref.getString("goods_driver_id");
      GetServerKey getServerKey = GetServerKey();
      String accessToken = await getServerKey.getServerKeyToken();
      print("serverKeyToken::$accessToken");
      if (accessToken.isEmpty) {
        showToast("No Token Found!");
        return;
      }

      final data = {
        'booking_id': userRideRequestInformationModel.bookingId,
        'booking_status': status,
        'server_token': accessToken,
        'customer_id': userRideRequestInformationModel.customerId
      };

      final response = await RequestAssistant.postRequest(
          '${serverEndPoint}/update_booking_status_driver', data);
      if (kDebugMode) {
        print(response);
      }
      await Future.delayed(Duration(seconds: 2));
      print("API Call Complete, Reloading Screen...");
      Navigator.pop(context); // Close dialog after successful update
      Navigator.pushNamed(context, NewTripDetailsRoute);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        showToast(
            "Already Assigned to Another Driver.\n Please be quick at receiving ride requests to earn more.");
        Navigator.pop(context);
      } else {
        // glb.showToast("Something Went Wrong");
        //glb.showToast("An error occurred while fetching booking details");
        // glb.showToast("An error occurred while fetching booking details: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveAndResetEndTripDetails(String status,
      {String? otp, String? amount, String? payment_method}) async {
    final pref = await SharedPreferences.getInstance();
    if (currentStatus == "Cancelled") {
      pref.setString("current_booking_id_assigned", "");
      glb.showToast("This Booking has been Cancelled");
      await Future.delayed(Duration(seconds: 3));
      streamSubscriptionDriverLivePosition?.cancel();
      Navigator.pushReplacementNamed(context, AgentHomeScreenRoute);
    }
    setState(() {
      isLoading = true;
    });
    print("Updating status to: $status");

    if (amount != null) print("Entered Amount: $amount");
    try {
      var driver_id = pref.getString("goods_driver_id");
      GetServerKey getServerKey = GetServerKey();
      String accessToken = await getServerKey.getServerKeyToken();
      print("serverKeyToken::$accessToken");
      if (accessToken.isEmpty) {
        showToast("No Token Found!");
        return;
      }

      final data = {
        'booking_id': userRideRequestInformationModel.bookingId,
        'payment_method': payment_method,
        'payment_id': -1,
        'booking_status': status,
        'server_token': accessToken,
        'driver_id': driver_id,
        'customer_id': userRideRequestInformationModel.customerId
      };

      final response = await RequestAssistant.postRequest(
          '${serverEndPoint}/generate_order_id_for_booking_id_goods_driver',
          data);
      if (kDebugMode) {
        print(response);
      }
      pref.setString("current_booking_id_assigned", "");
      await Future.delayed(Duration(seconds: 3));
      streamSubscriptionDriverLivePosition?.cancel();
      print("Trip Ended Here so stop drivers live location updates here");
      Navigator.pop(context); // Close dialog after successful update
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        showToast(
            "Already Assigned to Another Driver.\n Please be quick at receiving ride requests to earn more.");
        Navigator.pop(context);
      } else {
        // glb.showToast("Something Went Wrong");
        //glb.showToast("An error occurred while fetching booking details");
        // glb.showToast("An error occurred while fetching booking details: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoTheme(
          data: CupertinoThemeData(brightness: Brightness.light),
          child: CupertinoAlertDialog(
            title: Text("Enter OTP"),
            content: Column(
              children: [
                SizedBox(height: 8),
                CupertinoTextField(
                  controller: _otpController,
                  placeholder: "Enter OTP",
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: Text("Update"),
                onPressed: () {
                  if (_otpController.text.isNotEmpty) {
                    if (userRideRequestInformationModel.otp ==
                        _otpController.text.toString().trim()) {
                      Navigator.pop(context);
                      _updateStatus("OTP Verified", otp: _otpController.text);
                    }
                  } else {
                    glb.showToast("Please provide a valid OTP");
                    return;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDialog(String status) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoTheme(
          data: CupertinoThemeData(brightness: Brightness.light),
          child: CupertinoAlertDialog(
            title: Text(
                status == "Start Trip" ? "Start the trip?" : "End the trip?"),
            actions: [
              CupertinoDialogAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: Text("Update"),
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus(status);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentDialog(String amount) {
    String _selectedPaymentType = "Cash";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoTheme(
              data: CupertinoThemeData(brightness: Brightness.light),
              child: CupertinoAlertDialog(
                title: Text("Payment Details"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text("Amount to be paid:", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text(
                      "₹$amount",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text("Select Payment Type:",
                        style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    CupertinoSegmentedControl<String>(
                      groupValue: _selectedPaymentType,
                      onValueChanged: (value) {
                        setState(() {
                          _selectedPaymentType = value!;
                        });
                      },
                      children: {
                        "Cash": Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Cash"),
                        ),
                        "Online": Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Online"),
                        ),
                      },
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (_selectedPaymentType == "Online")
                    CupertinoDialogAction(
                      child: Text("Take Payment"),
                      onPressed: () {
                        // Handle online payment
                        print("Redirecting to online payment gateway...");
                        var totalAmount =
                            userRideRequestInformationModel.totalPrice!.round();

                        print("totalAmount to pay::$totalAmount");
                        //Navigator.pop(context);
                        _razorpay = Razorpay();
                        Razorpay razorpay = Razorpay();
                        var options = {
                          'key': glb.razorpay_key,
                          'amount': '$totalAmount',
                          'name': 'VT Partner Trans Pvt Ltd',
                          'description': 'Goods Delivery Service Payment',
                          'retry': {'enabled': true, 'max_count': 1},
                          'send_sms_hash': true,
                          'experiments.upi_turbo': true,
                          'prefill': {
                            'contact':
                                '${userRideRequestInformationModel.receiverNumber}',
                            'email': 'test@razorpay.com'
                          },
                          'theme': {'color': '#0042D9'},
                          'external': {
                            'wallets': ['paytm']
                          }
                        };
                        // var options = {
                        //   'amount': 10000,
                        //   'currency': 'INR',
                        //   'prefill': {
                        //     'contact':
                        //         '${userRideRequestInformationModel.receiverNumber}',
                        //     'email': 'test@razorpay.com'
                        //   },
                        //   'theme': {'color': '#0CA72F'},
                        //   'send_sms_hash': true,
                        //   'retry': {'enabled': false, 'max_count': 4},
                        //   'key': glb.razorpay_key,
                        //   'order_id':
                        //       '${userRideRequestInformationModel.bookingId}',
                        //   'disable_redesign_v15': false,
                        //   'experiments.upi_turbo': true,
                        //   'ep':
                        //       'https://api-web-turbo-upi.ext.dev.razorpay.in/test/checkout.html?branch=feat/turbo/tpv'
                        // };
                        razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                            handlePaymentErrorResponse);
                        razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                            handlePaymentSuccessResponse);
                        razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                            handleExternalWalletSelected);
                        razorpay.open(options);
                      },
                    ),
                  if (_selectedPaymentType == "Cash")
                    CupertinoDialogAction(
                      child: Text("Confirm"),
                      onPressed: () {
                        // Update status with Cash payment
                        Navigator.pop(context);
                        /**
                         * Update Status to End Trip
                         * Generate order id
                         * Free Driver Status to available again current_status = 1
                         * Add to Drivers Earning table with Order ID
                         * Decrement from drivers top up table point with the amount
                         * Remove the Shared Preference current_booking_id_assigned 
                         */
                        _saveAndResetEndTripDetails("End Trip",
                            amount: amount,
                            payment_method: _selectedPaymentType);
                        //
                        // _updateStatus("Trip Ended",
                        //     amount: amount,
                        //     payment_method: _selectedPaymentType);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    // * PaymentFailureResponse contains three values:
    // * 1. Error Code
    // * 2. Error Description
    // * 3. Metadata
    // *
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    // * Payment Success Response contains three values:
    // * 1. Order ID
    // * 2. Payment ID
    // * 3. Signature
    // *
    showAlertDialog(
        context, "Payment Successful", "Payment ID: ${response.paymentId}");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  // void openMap(double pickupLat, double pickupLng, double dropLat,
  //     double dropLng) async {
  //   String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin='
  //       '${Uri.encodeComponent(pickupLat.toString())},${Uri.encodeComponent(pickupLng.toString())}'
  //       '&destination=${Uri.encodeComponent(dropLat.toString())},'
  //       '${Uri.encodeComponent(dropLng.toString())}&travelmode=driving';
  //   final Uri uri = Uri.parse(googleMapsUrl);
  //   // String googleMapsUrl =
  //   //     "https://www.google.com/maps/dir/?api=1&origin=$pickupLat,$pickupLng&destination=$dropLat,$dropLng&travelmode=driving";
  //   // if (await canLaunch(googleMapsUrl)) {
  //   //   await launch(googleMapsUrl);
  //   // } else {
  //   //   throw 'Could not launch map app';
  //   // }
  //   // Attempt to launch the URL explicitly for the Google Maps app
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(
  //       uri,
  //       mode: LaunchMode.externalApplication, // Ensures Google Maps app is used
  //     );
  //   } else {
  //     throw 'Could not launch Google Maps';
  //   }
  // }

  void openMap(double pickupLat, double pickupLng, double dropLat,
      double dropLng) async {
    String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin='
        '${Uri.encodeComponent(pickupLat.toString())},${Uri.encodeComponent(pickupLng.toString())}'
        '&destination=${Uri.encodeComponent(dropLat.toString())},'
        '${Uri.encodeComponent(dropLng.toString())}'
        '&travelmode=driving'; // Key for starting navigation

    final Uri uri = Uri.parse(googleMapsUrl);

    // Attempt to launch the URL explicitly for the Google Maps app
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault, // Ensures Google Maps app is used
      );
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    // createDriverIconMarker();
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
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
          : Stack(
              children: [
                //google map
                currentStatus != null && currentStatus.isNotEmpty
                    ? GoogleMap(
                        padding: EdgeInsets.only(bottom: mapPadding),
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        initialCameraPosition: _kGooglePlex,
                        markers: setOfMarkers,
                        // circles: setOfCircle,
                        polylines: setOfPolyline,
                        onMapCreated: (GoogleMapController controller) {
                          _controllerGoogleMap.complete(controller);
                          newTripGoogleMapController = controller;

                          setState(() {
                            mapPadding = 450;
                          });
                          getDriversLocationUpdatesAtRealTime();
                          //black theme google map
                          // blackThemeGoogleMap(newTripGoogleMapController);
                          var driverCurrentLatLng = LatLng(
                              driverCurrentPosition!.latitude,
                              driverCurrentPosition!.longitude);
                          print("driverCurrentLatLng::$driverCurrentLatLng");
                          var userLatLng;
                          print("currentStatus::$currentStatus");
                          if (currentStatus == "Start Trip") {
                            print(
                                "started trip show drop location from current driver location");
                            userLatLng =
                                userRideRequestInformationModel.dropLatLng;
                            print("userPickUpLatLng::$userLatLng");
                          } else {
                            print(
                                "started trip show pickup location from current driver location");
                            userLatLng =
                                userRideRequestInformationModel.pickupLatLng;
                          }

                          drawPolyLineFromOriginToDestination(
                              driverCurrentLatLng, userLatLng!);
                        },
                      )
                    : Text('Please Reload the screen'),

                Positioned(
                  top: 50,
                  left: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, AgentHomeScreenRoute);
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_left,
                          size: 40,
                          color: Colors.black,
                        )),
                  ),
                ),
                Positioned(
                  bottom: 500,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          onPressed: () {
                            var driverCurrentLatLng = LatLng(
                                driverCurrentPosition!.latitude,
                                driverCurrentPosition!.longitude);
                            print("driverCurrentLatLng::$driverCurrentLatLng");
                            LatLng userLatLng;
                            print("currentStatus::$currentStatus");
                            if (currentStatus == "Start Trip") {
                              print(
                                  "started trip show drop location from current driver location");
                              userLatLng =
                                  userRideRequestInformationModel.dropLatLng!;
                              print("userPickUpLatLng::$userLatLng");
                            } else {
                              print(
                                  "started trip show pickup location from current driver location");
                              userLatLng =
                                  userRideRequestInformationModel.pickupLatLng!;
                            }
                            openMap(
                                driverCurrentLatLng.latitude,
                                driverCurrentLatLng.longitude,
                                userLatLng.latitude,
                                userLatLng.longitude);
                          },
                          icon: Icon(Icons.navigation)),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          onPressed: () async {
                            final Uri phoneUri = Uri(
                              scheme: 'tel',
                              path: currentStatus == "Start Trip"
                                  ? userRideRequestInformationModel
                                      .receiverNumber
                                  : userRideRequestInformationModel
                                      .senderNumber,
                            );
                            if (await canLaunchUrl(phoneUri)) {
                              await launchUrl(phoneUri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not launch phone call'),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.call,
                            color: Colors.green[900],
                          )),
                    ),
                  ),
                ),
                //ui
                // Positioned(
                //   bottom: 0,
                //   left: 0,
                //   right: 0,
                //   child: Container(
                //     decoration: const BoxDecoration(
                //       color: Colors.black,
                //       borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(18),
                //       ),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.white30,
                //           blurRadius: 18,
                //           spreadRadius: .5,
                //           offset: Offset(0.6, 0.6),
                //         ),
                //       ],
                //     ),
                //     child: Padding(
                //       padding:
                //           const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                //       child: Column(
                //         children: [
                //           //duration
                //           Text(
                //             durationFromOriginToDestination,
                //             style: const TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.lightGreenAccent,
                //             ),
                //           ),

                //           const SizedBox(
                //             height: 18,
                //           ),

                //           const Divider(
                //             thickness: 2,
                //             height: 2,
                //             color: Colors.grey,
                //           ),

                //           const SizedBox(
                //             height: 8,
                //           ),

                //           //user name - icon
                //           Row(
                //             children: [
                //               Text(
                //                 userRideRequestInformationModel!.customerName!,
                //                 style: const TextStyle(
                //                   fontSize: 20,
                //                   fontWeight: FontWeight.bold,
                //                   color: Colors.lightGreenAccent,
                //                 ),
                //               ),
                //               const Padding(
                //                 padding: EdgeInsets.all(10.0),
                //                 child: Icon(
                //                   Icons.phone_android,
                //                   color: Colors.grey,
                //                 ),
                //               ),
                //             ],
                //           ),

                //           const SizedBox(
                //             height: 18,
                //           ),

                //           //user PickUp Address with icon
                //           Row(
                //             children: [
                //               // Image.asset(
                //               //   "assetsimages/origin.png",
                //               //   width: 30,
                //               //   height: 30,
                //               // ),
                //               const SizedBox(
                //                 width: 14,
                //               ),
                //               Expanded(
                //                 child: Container(
                //                   child: Text(
                //                     userRideRequestInformationModel!
                //                         .pickupAddress!,
                //                     style: const TextStyle(
                //                       fontSize: 16,
                //                       color: Colors.grey,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),

                //           const SizedBox(height: 20.0),

                //           //user DropOff Address with icon
                //           Row(
                //             children: [
                //               // Image.asset(
                //               //   "images/destination.png",
                //               //   width: 30,
                //               //   height: 30,
                //               // ),
                //               const SizedBox(
                //                 width: 14,
                //               ),
                //               Expanded(
                //                 child: Container(
                //                   child: Text(
                //                     userRideRequestInformationModel!
                //                         .dropAddress!,
                //                     style: const TextStyle(
                //                       fontSize: 16,
                //                       color: Colors.grey,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),

                //           const SizedBox(
                //             height: 24,
                //           ),

                //           const Divider(
                //             thickness: 2,
                //             height: 2,
                //             color: Colors.grey,
                //           ),

                //           const SizedBox(height: 10.0),

                //           ElevatedButton.icon(
                //             onPressed: () async {
                //               //[driver has arrived at user PickUp Location] - Arrived Button
                //               if (rideRequestStatus == "accepted") {
                //                 rideRequestStatus = "arrived";

                //                 // FirebaseDatabase.instance.ref()
                //                 //     .child("All Ride Requests")
                //                 //     .child(userRideRequestInformationModel!.rideRequestId!)
                //                 //     .child("status")
                //                 //     .set(rideRequestStatus);

                //                 setState(() {
                //                   buttonTitle = "Let's Go"; //start the trip
                //                   buttonColor = Colors.lightGreen;
                //                 });

                //                 showDialog(
                //                   context: context,
                //                   barrierDismissible: false,
                //                   builder: (BuildContext c) =>
                //                       CircularProgressIndicator(),
                //                 );

                //                 await drawPolyLineFromOriginToDestination(
                //                     userRideRequestInformationModel!
                //                         .pickupLatLng!,
                //                     userRideRequestInformationModel!
                //                         .dropLatLng!);

                //                 Navigator.pop(context);
                //               }
                //               //[user has already sit in driver's car. Driver start trip now] - Lets Go Button
                //               else if (rideRequestStatus == "arrived") {
                //                 rideRequestStatus = "ontrip";

                //                 // FirebaseDatabase.instance.ref()
                //                 //     .child("All Ride Requests")
                //                 //     .child(userRideRequestInformationModel!.rideRequestId!)
                //                 //     .child("status")
                //                 //     .set(rideRequestStatus);

                //                 setState(() {
                //                   buttonTitle = "End Trip"; //end the trip
                //                   buttonColor = Colors.redAccent;
                //                 });
                //               }
                //               //[user/Driver reached to the dropOff Destination Location] - End Trip Button
                //               else if (rideRequestStatus == "ontrip") {
                //                 endTripNow();
                //               }
                //             },
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: buttonColor,
                //             ),
                //             icon: const Icon(
                //               Icons.directions_car,
                //               color: Colors.white,
                //               size: 25,
                //             ),
                //             label: Text(
                //               buttonTitle!,
                //               style: const TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
      bottomSheet: isLoading
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
          : Container(
              height: 450,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.2),
                //     spreadRadius: 2,
                //     blurRadius: 5,
                //     offset: const Offset(0, -3),
                //   ),
                // ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time Required: ${userRideRequestInformationModel.totalTime}',
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.green[900]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Fare Amount: Rs.${userRideRequestInformationModel.totalPrice}/-',
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Current Status : ${currentStatus}',
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance: ${userRideRequestInformationModel.totalDistance} KM',
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.blue[900]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Booking ID: ${userRideRequestInformationModel.bookingId}',
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: kHeight,
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 4.0,
                          right: 4.0,
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
                                        height: 60,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      SizedBox(
                                        width: width - 100,
                                        child: Text(
                                          userRideRequestInformationModel
                                              .pickupAddress!,
                                          style: nunitoSansStyle.copyWith(
                                              color: Colors.grey,
                                              fontSize: 12.0),
                                          overflow: TextOverflow
                                              .visible, // Adds ellipsis when text overflows
                                          maxLines:
                                              3, // Limits the text to a single line
                                        ),
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
                                      SizedBox(
                                        width: width - 100,
                                        child: Text(
                                          userRideRequestInformationModel
                                              .dropAddress!,
                                          style: nunitoSansStyle.copyWith(
                                              color: Colors.grey,
                                              fontSize: 12.0),
                                          overflow: TextOverflow
                                              .visible, // Adds ellipsis when text overflows
                                          maxLines:
                                              3, // Limits the text to a single line
                                        ),
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
                    SizedBox(height: kHeight - 15),
                    Divider(color: Colors.grey, thickness: 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_3,
                              size: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sender Details',
                                    style: nunitoSansStyle.copyWith(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    userRideRequestInformationModel.senderName!,
                                    style: nunitoSansStyle.copyWith(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    userRideRequestInformationModel
                                        .senderNumber!,
                                    style: nunitoSansStyle.copyWith(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person_3,
                              size: 15,
                              color: Colors.green[900],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receiver Details',
                                    style: nunitoSansStyle.copyWith(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    userRideRequestInformationModel
                                        .receiverName!,
                                    style: nunitoSansStyle.copyWith(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    userRideRequestInformationModel
                                        .receiverNumber!,
                                    style: nunitoSansStyle.copyWith(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: kHeight),
                    isLoading
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
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                if (nextStatus ==
                                    "Update to Arrived Location") {
                                  _updateStatus("Driver Arrived");
                                  // _showPaymentDialog(payAmount);
                                } else if (nextStatus == "Verify OTP") {
                                  _showOTPDialog();
                                } else if (nextStatus == "Start Trip") {
                                  _showConfirmDialog("Start Trip");
                                } else if (nextStatus == "End Trip") {
                                  var payAmount =
                                      userRideRequestInformationModel.totalPrice
                                          .toString();
                                  _showPaymentDialog(payAmount);
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/buttton_bg.png"),
                                      fit: BoxFit.cover),
                                  color: nextStatus == "Start Trip"
                                      ? Colors.green[900]
                                      : nextStatus == "End Trip"
                                          ? Colors.red
                                          : ThemeClass.facebookBlue,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            nextStatus,
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
            ),
    );
  }

  endTripNow() async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) => CircularProgressIndicator(),
    // );

    //get the tripDirectionDetails = distance travelled
    var currentDriverPositionLatLng = LatLng(
      onlineDriverCurrentPosition!.latitude,
      onlineDriverCurrentPosition!.longitude,
    );

    var tripDirectionDetails =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            currentDriverPositionLatLng,
            userRideRequestInformationModel!.pickupLatLng!);

    //fare amount
    // double totalFareAmount =
    //     AssistantMethods.calculateFareAmountFromOriginToDestination(
    //         tripDirectionDetails!);

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("All Ride Requests")
    //     .child(userRideRequestInformationModel!.rideRequestId!)
    //     .child("fareAmount")
    //     .set(totalFareAmount.toString());

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("All Ride Requests")
    //     .child(userRideRequestInformationModel!.rideRequestId!)
    //     .child("status")
    //     .set("ended");

//Clear shared Preference key value also
    streamSubscriptionDriverLivePosition!.cancel();

    Navigator.pop(context);

    //display fare amount in dialog box
    // showDialog(
    //   context: context,
    //   builder: (BuildContext c) => FareAmountCollectionDialog(
    //     totalFareAmount: totalFareAmount,
    //   ),
    // );

    //save fare amount to driver total earnings
    //saveFareAmountToDriverEarnings(totalFareAmount);
  }

  // saveFareAmountToDriverEarnings(double totalFareAmount) {
  //   FirebaseDatabase.instance
  //       .ref()
  //       .child("drivers")
  //       .child(currentFirebaseUser!.uid)
  //       .child("earnings")
  //       .once()
  //       .then((snap) {
  //     if (snap.snapshot.value != null) //earnings sub Child exists
  //     {
  //       //12
  //       double oldEarnings = double.parse(snap.snapshot.value.toString());
  //       double driverTotalEarnings = totalFareAmount + oldEarnings;

  //       FirebaseDatabase.instance
  //           .ref()
  //           .child("drivers")
  //           .child(currentFirebaseUser!.uid)
  //           .child("earnings")
  //           .set(driverTotalEarnings.toString());
  //     } else //earnings sub Child do not exists
  //     {
  //       FirebaseDatabase.instance
  //           .ref()
  //           .child("drivers")
  //           .child(currentFirebaseUser!.uid)
  //           .child("earnings")
  //           .set(totalFareAmount.toString());
  //     }
  //   });
  // }

  // saveAssignedDriverDetailsToUserRideRequest() {
  //   DatabaseReference databaseReference = FirebaseDatabase.instance
  //       .ref()
  //       .child("All Ride Requests")
  //       .child(userRideRequestInformationModel!.rideRequestId!);

  //   Map driverLocationDataMap = {
  //     "latitude": driverCurrentPosition!.latitude.toString(),
  //     "longitude": driverCurrentPosition!.longitude.toString(),
  //   };
  //   databaseReference.child("driverLocation").set(driverLocationDataMap);

  //   databaseReference.child("status").set("accepted");
  //   databaseReference.child("driverId").set(onlineDriverData.id);
  //   databaseReference.child("driverName").set(onlineDriverData.name);
  //   databaseReference.child("driverPhone").set(onlineDriverData.phone);
  //   databaseReference.child("car_details").set(
  //       onlineDriverData.car_color.toString() +
  //           " " +
  //           onlineDriverData.car_model.toString() +
  //           " " +
  //           onlineDriverData.car_number.toString());

  //   //saveRideRequestIdToDriverHistory();
  // }

  // saveRideRequestIdToDriverHistory()
  // {
  //   DatabaseReference tripsHistoryRef = FirebaseDatabase.instance.ref()
  //                                       .child("drivers")
  //                                       .child(currentFirebaseUser!.uid)
  //                                       .child("tripsHistory");
  //
  //   tripsHistoryRef.child(userRideRequestInformationModel!.rideRequestId!).set(true);
  // }
}
