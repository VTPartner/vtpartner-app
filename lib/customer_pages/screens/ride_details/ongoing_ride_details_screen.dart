import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/animation/fade_animation.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/ongoing_booking_model.dart';
import 'package:vt_partner/delivery_agent_pages/models/user_ride_request_information.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/shimmer_card.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'dart:async';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../../utils/app_styles.dart';

class CustomerOngoingRideDetailsScreen extends StatefulWidget {
  const CustomerOngoingRideDetailsScreen({super.key});

  @override
  State<CustomerOngoingRideDetailsScreen> createState() =>
      _CustomerOngoingRideDetailsScreenState();
}

class _CustomerOngoingRideDetailsScreenState
    extends State<CustomerOngoingRideDetailsScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;
//15.892953, 74.518013
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 14.4746,
  );
  LatLng? driverCurrentLatLng;
  String driver_arrivalDistance = "0Km", driver_arrivalTime = "0 min";
  
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

  bool isLoading = true;
  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};
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

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  OngoingBookingModel ongoingBookingModel = OngoingBookingModel();

  Future<void> getBookingDetails() async {
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();

    //booking_details_live_track
    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/booking_details_live_track',
          {'booking_id': glb.booking_id});
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
        var ratings = result['ratings'].toString();

        var distance = result['distance'].toString();
        var pickup_lat = double.parse(result['pickup_lat'].toString());
        var pickup_lng = double.parse(result['pickup_lng'].toString());
        var destination_lat =
            double.parse(result['destination_lat'].toString());
        var destination_lng =
            double.parse(result['destination_lng'].toString());

        ongoingBookingModel.pickupLatLng = LatLng(pickup_lat, pickup_lng);
        ongoingBookingModel.dropLatLng =
            LatLng(destination_lat, destination_lng);
        ongoingBookingModel.customerName = customer_name;
        ongoingBookingModel.customerId = customer_id;
        ongoingBookingModel.totalDistance = distance;
        ongoingBookingModel.pickupAddress = pickup_address;
        ongoingBookingModel.dropAddress = drop_address;
        ongoingBookingModel.ratings = ratings;
    
        ongoingBookingModel.driverName = driverName;
        ongoingBookingModel.driverMobileNo = driverMobileNo;
        ongoingBookingModel.bookingTiming =
            glb.formatEpochToDateTime(double.parse(bookingTiming));
        ongoingBookingModel.paymentMethod = paymentMethod;
        ongoingBookingModel.bookingStatus = bookingStatus;
        ongoingBookingModel.senderName = senderName;
        ongoingBookingModel.senderNumber = senderNumber;
        ongoingBookingModel.receiverName = receiverName;
        ongoingBookingModel.receiverNumber = receiverNumber;
        ongoingBookingModel.vehicleName = vehicleName;
        ongoingBookingModel.totalPrice = totalPrice;
        ongoingBookingModel.otp = otp;
        ongoingBookingModel.driverId = driver_id;
        ongoingBookingModel.vehicleImage = vehicle_image;
        ongoingBookingModel.pickupLat = pickup_lat;
        ongoingBookingModel.pickupLng = pickup_lng;
        ongoingBookingModel.dropLat = destination_lat;
        ongoingBookingModel.dropLng = destination_lng;

        ongoingBookingModel.vehiclePlateNo = vehiclePlateNo;
        ongoingBookingModel.vehicleFuelType = vehicleFuelType;
        ongoingBookingModel.driverImage = driverProfilePic;
        isLoading = false;
        setState(() {});
        if (bookingStatus != "Cancelled")
          getDriversLiveLocation();
        else
          await drawPolyLineFromOriginToDestination(
              ongoingBookingModel.pickupLatLng!,
              ongoingBookingModel.dropLatLng!);
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
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  Future<void> asyncCancelBooking() async {
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();

    //booking_details_live_track
    try {
      GetServerKey getServerKey = GetServerKey();
      String accessToken = await getServerKey.getServerKeyToken();
      print("serverKeyToken::$accessToken");
      pref.setString("serverKey", accessToken);

      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/cancel_booking', {
        'booking_id': glb.booking_id,
        'customer_id': ongoingBookingModel.customerId,
        'driver_id': ongoingBookingModel.driverId,
        'pickup_address': ongoingBookingModel.pickupAddress,
        'server_token': accessToken,
      });
      if (kDebugMode) {
        print(response);
      }

      Navigator.pushReplacementNamed(context, CustomerMainScreenRoute);
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

  Color _getStatusColor(String status) {
    switch (status) {
      case "Driver Accepted":
        return Colors.blue; // Example: Blue for "Driver Accepted"
      case "Driver Arrived":
        return Colors.orange; // Example: Orange for "Driver Arrived"
      case "OTP Verified":
        return Colors.indigo; // Example: Green for "OTP Verified"
      case "Start Trip":
        return const Color.fromARGB(
            255, 1, 81, 3); // Example: Red for "Start Trip"
      default:
        return Colors.grey; // Example: Grey for other statuses
    }
  }

  void _startLiveLocationUpdates() {
    // _timer = Timer.periodic(Duration(seconds: 30), (timer) {
    //   print("fetch drivers live location again");
    //   //getDriversLiveLocation();
    // });
  }

  Future<void> getDriversLiveLocation() async {
    //booking_details_live_track
    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_current_location',
          {'driver_id': ongoingBookingModel.driverId});
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        var result = response['results'][0];
        var driver_latitude = result['current_lat'];
        var driver_longitude = result['current_lng'];

        driverCurrentLatLng = LatLng(driver_latitude, driver_longitude);
        if (ongoingBookingModel.bookingStatus == "Start Trip") {
          getDistanceAndTime(driver_latitude, driver_longitude,
              ongoingBookingModel.dropLat!, ongoingBookingModel.dropLng!);
          drawPolyLineFromOriginToDestination(
              driverCurrentLatLng!, ongoingBookingModel.dropLatLng!);
          _startLiveLocationUpdates();
        } else {
          getDistanceAndTime(driver_latitude, driver_longitude,
              ongoingBookingModel.pickupLat!, ongoingBookingModel.pickupLng!);
          drawPolyLineFromOriginToDestination(
              driverCurrentLatLng!, ongoingBookingModel.pickupLatLng!);
          _startLiveLocationUpdates();
        }

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

  Future<void> getDistanceAndTime(
      driverLat, driverLng, double pickupLat, double pickupLng) async {
    final apiKey = mapKey;

    final url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${driverLat},${driverLng}&destinations=$pickupLat,$pickupLng&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['rows'][0]['elements'][0]['status'] == 'OK') {
          driver_arrivalDistance =
              data['rows'][0]['elements'][0]['distance']['text'];
          driver_arrivalTime =
              data['rows'][0]['elements'][0]['duration']['text'];

          print("Distance: ${driver_arrivalDistance}");
          print("Estimated Time: ${driver_arrivalTime}");
          setState(() {});
        }
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
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

    if (ongoingBookingModel.bookingStatus == "Cancelled") {
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
    } else {
      displayDriverMarker(pickupLatLng, dropLatLng);
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

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  Future<void> displayDriverMarker(driverLatLng, dropLatLng) async {
    setState(() {
      setOfMarkers.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();
      createMarkers(driversMarkerSet, driverLatLng, dropLatLng);
    });
  }

  Future<void> createMarkers(driversMarkerSet, driverLatLng, dropLatLng) async {
    LatLng eachDriverActivePosition = driverLatLng!;

    BitmapDescriptor customIcon =
        await glb.getMarkerIconFromUrl(ongoingBookingModel.vehicleImage!);
    Marker marker = Marker(
      markerId: MarkerId("driver" + ongoingBookingModel.driverId.toString()),
      position: eachDriverActivePosition,
      // icon: activeNearbyIcon!,
      icon: customIcon,
      rotation: 360,
    );
    print("marker::$marker");
    driversMarkerSet.add(marker);

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: dropLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    driversMarkerSet.add(destinationMarker);

    setState(() {
      setOfMarkers = driversMarkerSet;
    });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();

    getBookingDetails();
  }

  Timer? _timer;
  Razorpay? _razorpay;
  double searchLocationContainerHeight = 220.0;
  var _showReceipt = false;

  @override
  void dispose() {
    newGoogleMapController?.dispose();
    _timer?.cancel();
    _razorpay!.clear(); // Removes all listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print('Payment Successful');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print('Payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print('External Wallet selected');
  }

  Future<void> _handleRefresh() async {
    checkIfLocationPermissionAllowed();

    getBookingDetails();
  }



  @override
  Widget build(BuildContext context) {
    if (ongoingBookingModel != null &&
        ongoingBookingModel.bookingStatus != "Cancelled") {
      createDriverIconMarker();
    }
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
                child: RefreshIndicator(
                onRefresh: (_handleRefresh),
                child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, CustomerMainScreenRoute);
                                        },
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.grey[900],
                                        )),
                                    Text(
                                      "Booking ID - ${glb.booking_id}",
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
                                      color: _getStatusColor(
                                          ongoingBookingModel.bookingStatus!)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${ongoingBookingModel.bookingStatus}',
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
                                  // myLocationEnabled: true,
                                  zoomGesturesEnabled: true,
                                  buildingsEnabled: true,
                                  
                                  zoomControlsEnabled: false,
                                  initialCameraPosition: _kGooglePlex,
                                  
                                  polylines: setOfPolyline,

                                  markers: setOfMarkers,
                                  onMapCreated:
                                      (GoogleMapController controller) {
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
                              Positioned(
                                bottom: 60,
                                left: 10,
                                child: Column(
                                  children: [
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //       color: Colors.white,
                                    //       borderRadius:
                                    //           BorderRadius.circular(12.0)),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 16.0, vertical: 6.0),
                                    //     child: Text(
                                    //       driver_arrivalTime,
                                    //       style: nunitoSansStyle.copyWith(
                                    //           fontWeight: FontWeight.bold),
                                    //     ),
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   height: 5,
                                    // ),
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //       color: Colors.white,
                                    //       borderRadius:
                                    //           BorderRadius.circular(12.0)),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 16.0, vertical: 6.0),
                                    //     child: Text(
                                    //       driver_arrivalDistance,
                                    //       style: nunitoSansStyle.copyWith(
                                    //           fontWeight: FontWeight.bold),
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 6.0),
                                        child: Text(
                                          "OTP : ${ongoingBookingModel.otp!}",
                                          style: nunitoSansStyle.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: IconButton(
                                        onPressed: () async {
                                          final Uri phoneUri = Uri(
                                            scheme: 'tel',
                                            path: ongoingBookingModel
                                                .driverMobileNo,
                                          );
                                          if (await canLaunchUrl(phoneUri)) {
                                            await launchUrl(phoneUri);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Could not launch phone call'),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.phone,
                                        )),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 100,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: IconButton(
                                        onPressed: () async {
                                          final Uri phoneUri = Uri(
                                            scheme: 'tel',
                                            path: '112',
                                          );
                                          if (await canLaunchUrl(phoneUri)) {
                                            await launchUrl(phoneUri);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Could not launch phone call'),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.sos,
                                          color: Colors.red,
                                        )),
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0)),
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
                                            DescriptionText(
                                                descriptionText:
                                                    "${ongoingBookingModel.senderName} - ${ongoingBookingModel.senderNumber}"),
                                            SizedBox(
                                              width: width - 80,
                                              child: BodyText1(
                                                  text: ongoingBookingModel
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
                                                    "${ongoingBookingModel.receiverName} - ${ongoingBookingModel.receiverNumber}"),
                                            SizedBox(
                                              width: width - 80,
                                              child: BodyText1(
                                                  text: ongoingBookingModel
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
                                            "${ongoingBookingModel.driverImage}",
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DescriptionText(
                                              descriptionText:
                                                  "${ongoingBookingModel.driverName}"),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SubTitleText(
                                                  subTitle:
                                                      "${ongoingBookingModel.vehicleName}"),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              SubTitleText(
                                                  subTitle:
                                                      " | ${ongoingBookingModel.vehiclePlateNo}"),
                                              SubTitleText(
                                                  subTitle:
                                                      " | ${ongoingBookingModel.vehicleFuelType}"),
                                            ],
                                          ),
                                          
                                          SubTitleText(
                                              subTitle:
                                                  "${ongoingBookingModel.bookingTiming}"),
                                          SubTitleText(
                                              subTitle:
                                                  "$driver_arrivalTime to Arrive")
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: 10.0,
                          // ),
                          // Container(
                          //   decoration: BoxDecoration(color: Colors.white),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         DescriptionText(
                          //             descriptionText: "RIDE DETAILS"),
                          //         SizedBox(
                          //           height: 10.0,
                          //         ),

                          //         Padding(
                          //           padding: const EdgeInsets.only(bottom: 8.0),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
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
                          //               DescriptionText(
                          //                   descriptionText: "Local"),
                          //             ],
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(bottom: 8.0),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Row(
                          //                 children: [
                          //                   CircleAvatar(
                          //                     radius: 30,
                          //                     backgroundColor: Colors.white,
                          //                     child: ClipOval(
                          //                       child: Image.network(
                          //                         "https://vtpartner.org/media/image_YoRjcDi.jpg",
                          //                         fit: BoxFit.cover,
                          //                         width: 20,
                          //                         height: 20,
                          //                       ),
                          //                     ),
                          //                   ),
                          //                   Text(
                          //                     "Driver Name",
                          //                     style: nunitoSansStyle.copyWith(
                          //                         color: Colors.grey[800],
                          //                         fontSize: Theme.of(context)
                          //                             .textTheme
                          //                             .bodySmall
                          //                             ?.fontSize),
                          //                     overflow: TextOverflow.visible,
                          //                   ),
                          //                 ],
                          //               ),
                          //               DescriptionText(
                          //                   descriptionText:
                          //                       "${ongoingBookingModel.driverName}"),
                          //             ],
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(bottom: 8.0),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
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
                          //               DescriptionText(
                          //                   descriptionText:
                          //                       "${ongoingBookingModel.vehicleName}"),
                          //             ],
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(bottom: 8.0),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
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
                          //                   descriptionText: ongoingBookingModel
                          //                       .bookingTiming!),
                          //             ],
                          //           ),
                          //         ),
                          //         Divider(
                          //           color: Colors.grey,
                          //           thickness: 0.1,
                          //         ),
                          //         Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.center,
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
                          SizedBox(
                            height: 10.0,
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
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
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
                                                  " ₹ ${ongoingBookingModel.totalPrice!}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
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
                                          DescriptionText(
                                              descriptionText: "₹ 0.0"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
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
                                          DescriptionText(
                                              descriptionText: "₹ 0.0"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
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
                                          DescriptionText(
                                              descriptionText: "₹ 0.0"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
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
                                          DescriptionText(
                                              descriptionText: "₹ 0.0"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
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
                                                "  (Rounded)",
                                                style: nunitoSansStyle.copyWith(
                                                    color: Colors.grey,
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.fontSize),
                                                overflow: TextOverflow.visible,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "₹ ${double.parse(ongoingBookingModel.totalPrice!).round()}",
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
                                    ongoingBookingModel.paymentMethod != "NA"
                                        ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
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
                                                      '${ongoingBookingModel.paymentMethod!}'),
                                            ],
                                          )
                                        ],
                                      ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          ongoingBookingModel.bookingStatus == "Driver Accepted"
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // asyncCancelBooking();
                                            glb.driverImage =
                                                ongoingBookingModel
                                                    .driverImage!;
                                            glb.driverName =
                                                ongoingBookingModel.driverName!;
                                            glb.customerId =
                                                ongoingBookingModel.customerId!;
                                            glb.driverId =
                                                ongoingBookingModel.driverId!;
                                            glb.pickupAddress =
                                                ongoingBookingModel
                                                    .pickupAddress!;
                                            Navigator.pushNamed(
                                                context, CancelBookingRoute);
                                          },
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .transparent, // Make the button transparent
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              border: Border.all(
                                                // Add an outline
                                                color:
                                                    Colors.red, // Outline color
                                                width: 2.0, // Outline width
                                              ),
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Text(
                                                        'Cancel Booking',
                                                        style: nunitoSansStyle
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .red, // Text color matches outline color
                                                                fontSize: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.fontSize),
                                                        overflow: TextOverflow
                                                            .visible,
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
                                            color: Colors.grey[800],
                                            fontSize: 11.5),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                )
                              : ongoingBookingModel.bookingStatus != "Cancelled"
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 30),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                _razorpay = Razorpay();
                                                Razorpay razorpay = Razorpay();
                                                var options = {
                                                  'key': glb.razorpay_key,
                                                  'amount':
                                                      '${double.parse(ongoingBookingModel.totalPrice!).round()}',
                                                  'name':
                                                      'VT Partner Trans Pvt Ltd',
                                                  'description':
                                                      'Order Payment',
                                                  'retry': {
                                                    'enabled': true,
                                                    'max_count': 1
                                                  },
                                                  'send_sms_hash': true,
                                                  'prefill': {
                                                    'contact':
                                                        '${ongoingBookingModel.senderNumber}',
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
                                                //     'contact': '9877597717',
                                                //     'email': 'pshibu567@gmail.com'
                                                //   },
                                                //   'theme': {'color': '#0CA72F'},
                                                //   'send_sms_hash': true,
                                                //   'retry': {'enabled': false, 'max_count': 4},
                                                //   'key': 'rzp_test_5sHeuuremkiApj',
                                                //   'order_id': 'order_N0fmkHxFIp7wQh',
                                                //   'disable_redesign_v15': false,
                                                //   'experiments.upi_turbo': true,
                                                //   'ep':
                                                //       'https://api-web-turbo-upi.ext.dev.razorpay.in/test/checkout.html?branch=feat/turbo/tpv'
                                                // };
                                                razorpay.on(
                                                    Razorpay
                                                        .EVENT_PAYMENT_ERROR,
                                                    handlePaymentErrorResponse);
                                                razorpay.on(
                                                    Razorpay
                                                        .EVENT_PAYMENT_SUCCESS,
                                                    handlePaymentSuccessResponse);
                                                razorpay.on(
                                                    Razorpay
                                                        .EVENT_EXTERNAL_WALLET,
                                                    handleExternalWalletSelected);
                                                razorpay.open(options);
                                              },
                                              child: Ink(
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .transparent, // Make the button transparent
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  border: Border.all(
                                                    // Add an outline
                                                    color: Colors
                                                        .blue, // Outline color
                                                    width: 2.0, // Outline width
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16.0),
                                                          child: Text(
                                                            'Pay Now',
                                                            style: nunitoSansStyle
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .blue, // Text color matches outline color
                                                                    fontSize: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.fontSize),
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
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
                                            "In the event of a payment failure through Razorpay, the transaction amount will be refunded to you within 48 hours. For more information, please refer to our Customer Guidelines.",
                                            style: nunitoSansStyle.copyWith(
                                                color: Colors.grey[800],
                                                fontSize: 11.5),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                        ],
                      );
                    }),
              )));
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

}
