import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:custom_info_window/custom_info_window.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/home/home.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/delivery_agent_pages/models/user_ride_request_information.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:vt_partner/global/global.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/routings/route_names.dart';

import 'package:vt_partner/themes/themes.dart';

class DriverAgentNewRideDetails extends StatefulWidget {
  const DriverAgentNewRideDetails({super.key});

  @override
  State<DriverAgentNewRideDetails> createState() =>
      _DriverAgentNewRideDetailsState();
}

class _DriverAgentNewRideDetailsState extends State<DriverAgentNewRideDetails> {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(22.572645, 88.363892),
    zoom: 12.00,
  );

  LatLng location = const LatLng(22.610658, 88.400720);
  List<Marker> allMarkers = [];

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  List<LatLng> polyLinePositionCoordinates = [];

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
        streamSubscriptionPosition?.cancel();
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
          // if (booking_status == "Driver Accepted") {
          //   currentStatus = "Booking accepted by the driver.";
          // } else if (booking_status == "Driver Arrived") {
          //   currentStatus = "Driver arrived at the pickup location.";
          // } else if (booking_status == "OTP Verified") {
          //   currentStatus = "Pickup completed, en route to delivery.";
          // } else {
          //   currentStatus = "Delivery completed successfully.";
          // }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : currentStatus.isNotEmpty
                ? SizedBox(
                    height: size.height,
                    width: size.width,
                    child: Stack(
                      children: [
                        googlmap(),
                        customInfoWindow(size),
                        header(context),
                        rideDetailsBottomSheet(size),
                      ],
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          color: greyShade3,
                          size: 30,
                        ),
                        heightSpace,
                        Text(
                          "Please Wait..",
                          style: semibold16Grey,
                        )
                      ],
                    ),
                  ));
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
          if (mapController != null) {
            setState(() {
              CameraPosition cameraPosition =
                  CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
              mapController!.animateCamera(
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

  double tolerance = 0.000001;

  bool isSameLocation(
      double? prevLat, double? prevLng, double currentLat, double currentLng) {
    if (prevLat == null || prevLng == null) {
      return false;
    }
    return (prevLat - currentLat).abs() < tolerance &&
        (prevLng - currentLng).abs() < tolerance;
  }

  updateDriversCurrentPosition(var latitude, var longitude) async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_previous_lat = pref.getDouble("goods_driver_current_lat");
    var goods_driver_previous_lng = pref.getDouble("goods_driver_current_lng");
    var goods_driver_id = pref.getString("goods_driver_id");
    // var condition = goods_driver_previous_lat != null &&
    //     goods_driver_previous_lat == latitude &&
    //     goods_driver_previous_lng != null &&
    //     goods_driver_previous_lng == longitude;
    print("Current Lat::$latitude");
    print("Current Lng::$longitude");
    var condition = isSameLocation(goods_driver_previous_lat,
        goods_driver_previous_lng, latitude, longitude);
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
      await pref.setDouble("goods_driver_current_lat", latitude);
      await pref.setDouble("goods_driver_current_lng", longitude);
      print("prev_latitude::$latitude");
      print("prev_longitude::$longitude");
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
  bool isInitialized = false;
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        AgentHomeScreenRoute,
        (Route<dynamic> route) => false,
      );
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
        'customer_id': userRideRequestInformationModel.customerId,
        'total_amount': double.parse(amount!).round(),
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        AgentHomeScreenRoute,
        (Route<dynamic> route) => false,
      );
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
                      "₹${double.parse(amount).round()}",
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
                  // if (_selectedPaymentType == "Online")
                  //   CupertinoDialogAction(
                  //     child: Text("Take Payment"),
                  //     onPressed: () {
                  //       // Handle online payment
                  //       print("Redirecting to online payment gateway...");
                  //       var totalAmount =
                  //           userRideRequestInformationModel.totalPrice!.round();

                  //       print("totalAmount to pay::$totalAmount");
                  //       //Navigator.pop(context);
                  //       _razorpay = Razorpay();
                  //       Razorpay razorpay = Razorpay();
                  //       var options = {
                  //         'key': glb.razorpay_key,
                  //         'amount': '$totalAmount',
                  //         'name': 'VT Partner Trans Pvt Ltd',
                  //         'description': 'Goods Delivery Service Payment',
                  //         'retry': {'enabled': true, 'max_count': 1},
                  //         'send_sms_hash': true,
                  //         'experiments.upi_turbo': true,
                  //         'prefill': {
                  //           'contact':
                  //               '${userRideRequestInformationModel.receiverNumber}',
                  //           'email': 'test@razorpay.com'
                  //         },
                  //         'theme': {'color': '#0042D9'},
                  //         'external': {
                  //           'wallets': ['paytm']
                  //         }
                  //       };
                  //       // var options = {
                  //       //   'amount': 10000,
                  //       //   'currency': 'INR',
                  //       //   'prefill': {
                  //       //     'contact':
                  //       //         '${userRideRequestInformationModel.receiverNumber}',
                  //       //     'email': 'test@razorpay.com'
                  //       //   },
                  //       //   'theme': {'color': '#0CA72F'},
                  //       //   'send_sms_hash': true,
                  //       //   'retry': {'enabled': false, 'max_count': 4},
                  //       //   'key': glb.razorpay_key,
                  //       //   'order_id':
                  //       //       '${userRideRequestInformationModel.bookingId}',
                  //       //   'disable_redesign_v15': false,
                  //       //   'experiments.upi_turbo': true,
                  //       //   'ep':
                  //       //       'https://api-web-turbo-upi.ext.dev.razorpay.in/test/checkout.html?branch=feat/turbo/tpv'
                  //       // };
                  //       razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                  //           handlePaymentErrorResponse);
                  //       razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                  //           handlePaymentSuccessResponse);
                  //       razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                  //           handleExternalWalletSelected);
                  //       razorpay.open(options);
                  //     },
                  //   ),

                  if (_selectedPaymentType == "Cash" ||
                      _selectedPaymentType == "Online")
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

  Map<PolylineId, Polyline> polylines = {};

  Future<void> getDirections(driverLat, driverLng, userLat, userLng) async {
    List<LatLng> polylineCoordinates = [];

    // Create the request object
    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(driverLat, driverLng),
      destination: PointLatLng(userLat, userLng),
      wayPoints: [PolylineWayPoint(location: 'Belgaum')],
      mode: TravelMode.driving,
    );

    // Get the route
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: request, googleApiKey: mapKey);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print("No polyline points found.");
    }

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    print("Adding polyline with ${polylineCoordinates.length} points.");
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: primaryColor,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  rideDetailsBottomSheet(size) {
    return AnimationConfiguration.synchronized(
      child: SlideAnimation(
        curve: Curves.easeIn,
        delay: const Duration(milliseconds: 350),
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 1,
          expand: true,
          builder: (context, scrollController) {
            return Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(10, 0),
                  )
                ],
              ),
              child: Column(
                children: [
                  heightSpace,
                  heightSpace,
                  indicator(),
                  heightSpace,
                  heightSpace,
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: fixPadding * 2.0),
                      controller: scrollController,
                      children: [
                        passangerProfileImage(context),
                        heightSpace,
                        passengerName(),
                        Text(
                          currentStatus,
                          style: regular14Grey,
                          textAlign: TextAlign.center,
                        ),
                        heightSpace,
                        rideFareAndDistance(),
                        heightSpace,
                        heightSpace,
                        const Text(
                          "Trip Route",
                          style: bold18Black,
                        ),
                        heightSpace,
                        tripRouteAddress(),
                        heightSpace,
                        heightSpace,
                        const Text(
                          "Other Info",
                          style: bold18Black,
                        ),
                        heightSpace,
                        Row(
                          children: [
                            otherItemWidget(
                                "Booking ID",
                                "# ${userRideRequestInformationModel.bookingId}",
                                ""),
                            otherItemWidget(
                                "Sender",
                                "${userRideRequestInformationModel.senderName}",
                                "${userRideRequestInformationModel.senderNumber}"),
                            otherItemWidget(
                                "Receiver",
                                "${userRideRequestInformationModel.receiverName}",
                                "${userRideRequestInformationModel.receiverNumber}")
                          ],
                        ),
                        heightSpace,
                      ],
                    ),
                  ),
                  rideButtons(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  otherItemWidget(title, content, number) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: semibold14Grey,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            content,
            style: bold12Primary,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            number,
            style: regular12Grey,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  divider() {
    return Container(
      height: 1,
      color: lightGreyColor,
      width: double.maxFinite,
    );
  }

  tripRouteAddress() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: secondaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${userRideRequestInformationModel.pickupAddress}",
                        style: semibold14Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // widthSpace,
                    // Text(
                    //   "11:20 am",
                    //   style: bold12Primary,
                    // )
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: fixPadding),
                child: DottedBorder(
                  padding: EdgeInsets.zero,
                  strokeWidth: 1.2,
                  dashPattern: const [1, 3],
                  color: blackColor,
                  strokeCap: StrokeCap.round,
                  child: Container(
                    height: 40,
                  ),
                ),
              ),
              widthSpace,
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  height: 1,
                  color: lightGreyColor,
                ),
              )
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${userRideRequestInformationModel.dropAddress}",
                        style: semibold14Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // widthSpace,
                    // Text(
                    //   "11:45 am",
                    //   style: bold12Primary,
                    // )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  indicator() {
    return Center(
      child: Container(
        width: 60,
        height: 5,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  passengerName() {
    return Text(
      "${userRideRequestInformationModel.customerName}",
      style: semibold17Black,
      textAlign: TextAlign.center,
    );
  }

  rideButtons() {
    return GestureDetector(
      onTap: () {
        if (nextStatus == "Update to Arrived Location") {
          _updateStatus("Driver Arrived");
          // _showPaymentDialog(payAmount);
        } else if (nextStatus == "Verify OTP") {
          _showOTPDialog();
        } else if (nextStatus == "Start Trip") {
          _showConfirmDialog("Start Trip");
        } else if (nextStatus == "End Trip") {
          var payAmount = userRideRequestInformationModel.totalPrice.toString();
          _showPaymentDialog(payAmount);
        }
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.3),
        decoration: BoxDecoration(
          color: nextStatus == "Start Trip"
              ? Colors.green[900]
              : nextStatus == "End Trip"
                  ? Colors.red
                  : primaryColor,
          boxShadow: buttonShadow,
        ),
        alignment: Alignment.center,
        child: Text(
          nextStatus,
          style: bold18White,
        ),
      ),
    );
  }

  rideFareAndDistance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                "Ride fare",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "\₹ ${userRideRequestInformationModel.totalPrice!.round()}",
                style: semibold15Black,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                "Distance",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${userRideRequestInformationModel.totalDistance} Km",
                style: semibold15Black,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                "Time Required",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${userRideRequestInformationModel.totalTime}",
                style: semibold15Black,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ],
    );
  }

  passangerProfileImage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: whiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 4),
              )
            ],
          ),
          alignment: Alignment.center,
          child: IconButton(
            onPressed: () async {
              final Uri phoneUri = Uri(
                scheme: 'tel',
                path: currentStatus == "Start Trip"
                    ? userRideRequestInformationModel.receiverNumber
                    : userRideRequestInformationModel.senderNumber,
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
            icon: const Icon(
              Icons.call,
              color: primaryColor,
              size: 16,
            ),
          ),
        ),
        widthSpace,
        widthSpace,
        Container(
          clipBehavior: Clip.hardEdge,
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage("assets/images/demo_user.jpg"),
            ),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              )
            ],
          ),
        ),
        widthSpace,
        widthSpace,
        InkWell(
          onTap: () {
            var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude);
            print("driverCurrentLatLng::$driverCurrentLatLng");
            LatLng userLatLng;
            print("currentStatus::$currentStatus");
            if (currentStatus == "Start Trip") {
              print(
                  "started trip show drop location from current driver location");
              userLatLng = userRideRequestInformationModel.dropLatLng!;
              print("userPickUpLatLng::$userLatLng");
            } else {
              print(
                  "started trip show pickup location from current driver location");
              userLatLng = userRideRequestInformationModel.pickupLatLng!;
            }
            openMap(driverCurrentLatLng.latitude, driverCurrentLatLng.longitude,
                userLatLng.latitude, userLatLng.longitude);
          },
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: whiteColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.location_fill,
              color: primaryColor,
              size: 16,
            ),
          ),
        )
      ],
    );
  }

  customInfoWindow(Size size) {
    return CustomInfoWindow(
      controller: _customInfoWindowController,
      width: 100,
      height: 40,
      offset: 50,
    );
  }

  googlmap() {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow!();
      },
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: currentPosition,
      onMapCreated: mapCreated,
      markers: Set.from(allMarkers),
      polylines: setOfPolyline,
    );
  }

  Set<Polyline> setOfPolyline = Set<Polyline>();

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
      if (mapController != null) {
        mapController!
            .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 85));
      }
    }
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    _customInfoWindowController.googleMapController = controller;
    getDriversLocationUpdatesAtRealTime();
    var driverCurrentLatLng = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    print("driverCurrentLatLng::$driverCurrentLatLng");
    var userLatLng;
    print("currentStatus::$currentStatus");
    if (currentStatus == "Start Trip") {
      print("started trip show drop location from current driver location");
      userLatLng = userRideRequestInformationModel.dropLatLng;
      print("userPickUpLatLng::$userLatLng");
    } else {
      print("started trip show pickup location from current driver location");
      userLatLng = userRideRequestInformationModel.pickupLatLng;
    }
    print(
        "Driver Position: ${driverCurrentPosition?.latitude}, ${driverCurrentPosition?.longitude}");
    print("User Position: ${userLatLng.latitude}, ${userLatLng.longitude}");
    // getDirections(
    //     driverCurrentPosition!.latitude,
    //     driverCurrentPosition!.longitude,
    //     userLatLng.latitude,
    //     userLatLng.longitude);
    drawPolyLineFromOriginToDestination(driverCurrentLatLng, userLatLng!);
    await marker(driverCurrentLatLng, userLatLng!);
    isInitialized = true;
    setState(() {});
  }

  marker(LatLng driverCurrentLatLng, LatLng userLatLng) async {
    allMarkers.clear();
    allMarkers.add(
      Marker(
        markerId: const MarkerId("drop location"),
        position: userLatLng,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor,
                border: Border.all(color: whiteColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "Island Pkwy",
                style: semibold12White,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            location,
          );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/drop.png", 130),
        ),
      ),
    );
    // BitmapDescriptor customIcon = await glb
    //     .getMarkerIconFromUrl(userRideRequestInformationModel.vehicle_images!);
    allMarkers.add(
      Marker(
        markerId: const MarkerId("location"),
        position: driverCurrentLatLng,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor,
                border: Border.all(color: whiteColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "Island Pkwy",
                style: semibold12White,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            location,
          );
        },
        anchor: const Offset(0.5, 0.4),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/ridestart/top - taxi.png", 80),
        ),
      ),
    );
  }

  header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: fixPadding,
          right: fixPadding,
          top: (Platform.isIOS) ? fixPadding * 5.0 : fixPadding * 3.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_sharp,
              color: blackColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }
}
