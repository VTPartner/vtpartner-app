import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:http/http.dart' as http;
import 'package:vt_partner/global/global.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/push_notifications/notification_service.dart';
import 'package:vt_partner/routings/route_names.dart';

import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/shimmer_card.dart';

class GoodsDriverHomeScreen extends StatefulWidget {
  const GoodsDriverHomeScreen({super.key, this.isonline});

  final bool? isonline;

  @override
  State<GoodsDriverHomeScreen> createState() => _GoodsDriverHomeScreenState();
}

class _GoodsDriverHomeScreenState extends State<GoodsDriverHomeScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PolylinePoints polylinePoints = PolylinePoints();
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  DateTime? backpressTime;

  bool isOnline = false;

  GoogleMapController? mapController;

  LatLng endLocation = const LatLng(22.610658, 88.400720);
  LatLng startLocation = const LatLng(22.555501, 88.347469);

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(22.572645, 88.363892),
    zoom: 12.00,
  );

  List<Marker> allMarkers = [];
  List<Marker> onlineallMarkers = [];
  Map<PolylineId, Polyline> polylines = {};

  bool isShowMore = false;

  Position? driverCurrentPosition;

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  Set<Marker> markersSet = {};
  BitmapDescriptor? customMarkerIcon;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    if (mapController != null) {
      mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

    BitmapDescriptor customIcon = await glb
        .getMarkerIconFromUrl("https://vtpartner.org/media/truck_1358750.png");

    // Add custom marker at the user's current location
    allMarkers.add(
      Marker(
          markerId: const MarkerId("your location"),
          position: latLngPosition,
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              Container(
                width: double.maxFinite,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: fixPadding),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      )
                    ]),
                alignment: Alignment.center,
                child: const Text(
                  "9 Bailey Drive, Fredericton, NB E3B 5A3",
                  style: semibold14Black,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              latLngPosition,
            );
          },
          icon: customIcon),
    );

    setState(() {});
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  File? _ownerSelfieFront;
  String? previousSelfie;
  CameraController? cameraController;
  bool _isCameraInitialized = false;

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousSelfie = pref.getString("recent_online_pic");
    List<CameraDescription> cameras = await availableCameras();

    // Find the front camera
    CameraDescription frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await cameraController?.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _uploadImage(File image, bool isFront) async {
    final pref = await SharedPreferences.getInstance();
    String url = '${glb.serverEndPointImage}/upload';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      // request.fields['driver_id'] = '1';
      // request.fields['side'] = isFront ? 'front' : 'back';
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      print("request::$request");
      var response = await request.send();
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(await response.stream.bytesToString());
        print("jsonBody::$jsonBody");
        print("jsonBody::${jsonBody["image_url"]}");
        //return jsonBody;
        var retUrl = jsonBody["image_url"];
        await pref.setString("recent_online_pic", retUrl);
        previousSelfie = retUrl;
        glb.showToast('Selfie image uploaded successfully');
        driverIsOnlineNow(); //Updating Driver Current Location and Searching for new ride requests
        updateDriversLocationAtRealTime(); // It will start sending realtime lat lng
        setState(() {
          isOnline = true;
        });
        // Navigator.pop(context);
      } else {
        glb.showToast('Failed to upload image');
        setState(() {
          isOnline = false;
        });
      }
    } catch (e) {
      glb.showToast('An error occurred: $e');
      setState(() {
        isOnline = false;
      });
    }
  }

  NotificationService notificationService = NotificationService();

  Future<void> getNotificationToken() async {
    notificationService.requestNotificationPermission();
    notificationService.getGoodsDriverDeviceToken();
    notificationService.isGoodsDriverTokenRefreshed();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    final pref = await SharedPreferences.getInstance();
    pref.setBool("openDriver", true);
    pref.setBool("openCustomer", false);
    GetServerKey getServerKey = GetServerKey();
    String accessToken = await getServerKey.getServerKeyToken();
    print("serverKeyToken::$accessToken");
    pref.setString("serverKey", accessToken);
    pref.setString("goods_drive_device_token", "");
    var device_token = pref.getString("goods_drive_device_token");
    if (device_token == null || device_token.isEmpty) {
      await notificationService.getGoodsDriverDeviceToken();
      updateDriverAuthToken();
    }
    // if (device_token != null && device_token.isNotEmpty) {
    //   SendNotificationService.sendNotificationUsingApi(
    //       token: device_token,
    //       title: 'New Ride Request',
    //       body: 'Pickup Location: New Vaibhav Nagar',
    //       data: {'intent': 'driver', 'booking_id': '1'});
    // }

    //FcmService.firebaseInit();
  }

  Future<void> updateDriverAuthToken() async {
    print("updating goods driver authToken");
    final pref = await SharedPreferences.getInstance();

    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userCurrentLocation?.locationLatitude;
    var longitude = appInfo.userCurrentLocation?.locationLongitude;
    var full_address = appInfo.userCurrentLocation?.locationName;
    var pincode = appInfo.userCurrentLocation?.pinCode;
    if (full_address == null) {
      MyApp.restartApp(context);
    }
    GetServerKey getServerKey = GetServerKey();
    String accessToken = await getServerKey.getServerKeyToken();
    var deviceToken = pref.getString("goods_drive_device_token");
    var goods_driver_id = pref.getString("goods_driver_id");
    if (deviceToken == null || deviceToken.isEmpty) {
      var token = await notificationService.getGoodsDriverDeviceToken();
      pref.setString("goods_drive_device_token", token);
      updateDriverAuthToken();
      return;
    }
    final data = {'goods_driver_id': goods_driver_id, 'authToken': deviceToken};

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/update_firebase_goods_driver_token', data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['message'] != null) {}
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      //glb.showToast("An error occurred: ${e.toString()}");
    }
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
    updateDriverStatusAsync(latitude, longitude);
    //And he is searching for a new ride . But first check his current status in backend
  }

  updateDriversLocationAtRealTime() {
    LatLng? oldLatLng; // Initialize to track the previous position

    print("isOnline::$isOnline");
    if (!isOnline) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        streamSubscriptionPosition?.cancel();
        // MyApp.restartApp(context);
      });
      return;
    }

    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      if (isOnline) {
        LatLng latLng = LatLng(
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

        // Only proceed if the location has changed
        if (oldLatLng == null ||
            oldLatLng!.latitude != latLng.latitude ||
            oldLatLng!.longitude != latLng.longitude) {
          oldLatLng = latLng;

          // Update in table
          Future.delayed(const Duration(milliseconds: 2000), () {
            updateDriversCurrentPosition(driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude);
          });

          // Update the map camera
          if (mapController != null) {
            mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
          }
        }
      }

      // If the driver goes offline, update the status
      if (!isOnline) {
        updateDriverStatusAsync(
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
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

    var condition = isSameLocation(goods_driver_previous_lat,
        goods_driver_previous_lng, latitude, longitude);
    // print("home screen location update condition::$condition");
    if (condition == true) return;

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
      pref.setDouble("goods_driver_current_lat", latitude);
      pref.setDouble("goods_driver_current_lng", longitude);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // //glb.showToast("An error occurred: ${e.toString()}");
      //glb.showToast("Something went wrong");
    }
  }

  driverIsOfflineNow() async {
    final pref = await SharedPreferences.getInstance();

    var current_booking_id = pref.getString("current_booking_id_assigned");
    if (current_booking_id != null && current_booking_id.isNotEmpty) {
      glb.showToast("You cant go Offline during live order");
      return;
    }
    pref.setString("recent_online_pic", "");
    previousSelfie == null;
    deleteFromActiveDriverTableAsync();

    //Async to make him go offline
  }

  void _showCameraPreviewDialog(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              if (_isCameraInitialized) CameraPreview(cameraController!),
              const SizedBox(height: 10),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: IconButton(
                  onPressed: () async {
                    try {
                      XFile picture = await cameraController!.takePicture();
                      Navigator.of(context)
                          .pop(true); // Indicate successful capture
                      setState(() {
                        _ownerSelfieFront = File(picture.path);
                        _uploadImage(_ownerSelfieFront!, true);
                      });
                    } catch (e) {
                      print("Error capturing image: $e");
                      setState(() {
                        isOnline = false;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.camera,
                    color: Colors.red,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((result) {
      // Check if dialog was canceled without taking a picture
      if (result == null) {
        setState(() {
          isOnline = false;
        });
      }
    });
  }

  //Update Online or Offline here
  Future<void> updateDriverStatusAsync(var latitude, var longitude) async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");
    var recent_online_pic = pref.getString("recent_online_pic");

    var status = 0;
    if (isOnline) {
      status = 1;
    }
    print("status::$status");
    final data = {
      'goods_driver_id': goods_driver_id,
      'status': status,
      'lat': latitude,
      'lng': longitude,
      'recent_online_pic': recent_online_pic
    };

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_update_online_status', data);
      if (kDebugMode) {
        print(response);
      }
      if (status == 1) addToActiveDriverTableAsync(latitude, longitude);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // //glb.showToast("An error occurred: ${e.toString()}");
      glb.showToast("Something went wrong");
    }
  }

  //Adding new entry to active goods_driver_table
  Future<void> addToActiveDriverTableAsync(var latitude, var longitude) async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");
    // var recent_online_pic = pref.getString("recent_online_pic");

    var status = 0;
    if (isOnline) {
      status = 1;
    }
    final data = {
      'goods_driver_id': goods_driver_id,
      'status': status,
      'current_lat': latitude,
      'current_lng': longitude,
    };

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/add_new_active_goods_driver', data);
      if (kDebugMode) {
        print(response);
      }
      glb.showToast("You are Online now");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // //glb.showToast("An error occurred: ${e.toString()}");
      glb.showToast("Something went wrong");
    }
  }

//Deleting  entry from active goods_driver_table when driver wants to go offline
  Future<void> deleteFromActiveDriverTableAsync() async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");
    // var recent_online_pic = pref.getString("recent_online_pic");

    final data = {
      'goods_driver_id': goods_driver_id,
    };

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/delete_active_goods_driver', data);
      if (kDebugMode) {
        print(response);
      }
      glb.showToast("You are offline now");
      setState(() {
        isOnline = false;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        streamSubscriptionPosition?.cancel();
        // MyApp.restartApp(context);
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // //glb.showToast("An error occurred: ${e.toString()}");
      glb.showToast("Something went wrong");
    }
  }

  bool isVerified = false, isLoading = true;
  String driverName = "", verifiedStatus = "", profilePic = "", mobileNo = "";
  double todaysEarnings = 0;
  var todaysRides = 0;

  Future<void> statusCheckAsync() async {
    final pref = await SharedPreferences.getInstance();

    pref.setString("recent_online_pic", "");
    var goods_driver_id = pref.getString("goods_driver_id");

    if (goods_driver_id == null || goods_driver_id.isEmpty) {
      Navigator.pushReplacementNamed(context, AgentLoginRoute);
      return;
    }
    final data = {
      'goods_driver_id': goods_driver_id,
    };

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_online_status', data);
      if (kDebugMode) {
        print(response);
      }

      if (response.containsKey("results")) {
        var ret = response["results"][0];
        var is_online = ret["is_online"].toString();
        setState(() {
          profilePic = ret["profile_pic"].toString();
          mobileNo = ret["mobile_no"].toString();
        });

        if (is_online == "1") {
          setState(() {
            isOnline = true;
            updateDriversLocationAtRealTime(); // It will start sending realtime lat lng
          });
        }
        /*
        {1}>Verified</
{2}>Blocked</
{3}>Rejected</
{0}>Not Verified
         */
        var status = ret["status"].toString(); //if verified or not
        var recent_online_pic =
            ret["recent_online_pic"].toString(); //if verified or not
        pref.setString("recent_online_pic", recent_online_pic);
        print("status::$status");
        if (status == "0") {
          setState(() {
            isVerified = false;
            verifiedStatus = "You are not yet verified";
          });
        } else if (status == "2" || status == "3") {
          setState(() {
            isVerified = false;
            if (status == "2") verifiedStatus = "You are blocked";
            if (status == "3") verifiedStatus = "You are rejected";
          });
        } else {
          setState(() {
            isVerified = true;
          });
        }

        setState(() {
          driverName = ret["driver_first_name"].toString();
          // driverName = ret["driver_first_name"].toString().split(' ')[0];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Data Found.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> driversTodaysEarningsAsync() async {
    final pref = await SharedPreferences.getInstance();

    var goods_driver_id = pref.getString("goods_driver_id");

    if (goods_driver_id == null || goods_driver_id.isEmpty) {
      Navigator.pushReplacementNamed(context, AgentLoginRoute);
      return;
    }
    final data = {
      'driver_id': goods_driver_id,
    };

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_todays_earnings', data);
      if (kDebugMode) {
        print(response);
      }

      if (response.containsKey("results")) {
        var ret = response["results"];
        todaysEarnings = ret[0]['todays_earnings'];
        todaysRides = ret[0]['todays_rides'];
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Data Found.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Set custom marker icon for the user's location
  void setCustomMarkerIcon() async {
    customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/3d_location.png', // Replace with your own marker asset
    );
  }

  void _toggleSwitch(bool value) {
    // Show confirmation dialog before toggling
    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Change Status'),
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
                setState(() {
                  isOnline = !isOnline;
                });
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Confirm',
                style: nunitoSansStyle.copyWith(
                    color: isOnline ? Colors.red : Colors.green),
              ),
              onPressed: () {
                if (limitExceededBalance > 0 || isExpired) {
                  Navigator.of(context).pop();
                  setState(() {
                    isOnline = false;
                  });
                  glb.showSnackBar(context,
                      "To continue receiving ride requests, please ensure your account is recharged.\nThank you for your prompt attention.");
                  return;
                }
                setState(() {
                  isOnline = value; // Update the state
                });
                Navigator.of(context).pop();
                if (isOnline) {
                  _showCameraPreviewDialog("front");
                } else {
                  driverIsOfflineNow();
                }
                //Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  String currentBalance = "0";
  double limitExceededBalance = 0;
  bool isExpired = false;

  Future<void> fetchCurrentBalance() async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");

    final data = {
      'driver_id': goods_driver_id,
    };

    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var address = appInfo.userCurrentLocation?.locationName;
    if (address == null || address.isEmpty) {
      MyApp.restartApp(context);
      // return;
    }

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_goods_driver_current_recharge_details',
          data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      bool hasNegativePoints = false;
      if (response['results'] != null) {
        var ret = response['results'];
        currentBalance = ret[0]['remaining_points'].toString();
        var negativePoints = ret[0]['negative_points'];

        print("negativePoints::$negativePoints");
        if (negativePoints > 0) {
          print("entered negative points");
          currentBalance = negativePoints.toString();
          limitExceededBalance = double.parse(currentBalance);
          hasNegativePoints = true;
          currentBalance = "-$currentBalance";
          setState(() {});
          glb.showSnackBar(context,
              "To continue receiving ride requests, please ensure your account is recharged.\nThank you for your prompt attention.");
        }

        var validTillDateStr = ret[0]['valid_till_date'];
        print("valid_till_date::$validTillDateStr");

// Convert valid_till_date to a DateTime object
        DateTime validTillDate = DateTime.parse(validTillDateStr);

// Get the current date
        DateTime currentDate = DateTime.now();

// Format both dates to "yyyy-MM-dd" to ensure only the date portion is compared
        String formattedValidTillDate =
            DateFormat('yyyy-MM-dd').format(validTillDate);
        String formattedCurrentDate =
            DateFormat('yyyy-MM-dd').format(currentDate);

        print("formattedCurrentDate::$formattedCurrentDate");
        print("formattedValidTillDate::$formattedValidTillDate");

// Parse the formatted dates back to DateTime objects to remove time
        DateTime parsedValidTillDate =
            DateTime.parse("$formattedValidTillDate 00:00:00");
        DateTime parsedCurrentDate =
            DateTime.parse("$formattedCurrentDate 00:00:00");

        print("parsedValidTillDate::$parsedValidTillDate");
        print("parsedCurrentDate::$parsedCurrentDate");

// Check if valid_till_date is before or on the current date
        print("hasNegativePoints::$hasNegativePoints");
        if (parsedValidTillDate.isBefore(parsedCurrentDate) ||
            parsedValidTillDate.isAtSameMomentAs(parsedCurrentDate)) {
          print("Valid till date is valid, no action needed.");
        } else {
          print("Valid till date is in the future. Updating balance to 0.");
          if (hasNegativePoints) {
            currentBalance =
                "-${limitExceededBalance.toString()}"; // Set to negative balance
            isExpired = true;
            glb.showSnackBar(context,
                "Your previous plan has expired. Please recharge promptly to continue receiving ride requests.");
          }
        }

        print("remaining_points::$currentBalance");
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showSnackBar(
            context, "Not Yet Subscribed to any Top-Up Recharge plan.");
      } else {
        //glb.showSnackBar(
        // context,"An error occurred: ${e.toString()}");
      }
    } finally {}
  }

  @override
  void initState() {
    // getDirections();
    // setState(() {
    //   isOnline = widget.isonline ?? false;
    // });

    getNotificationToken();
    _setupCameraController();
    setCustomMarkerIcon();
    checkIfLocationPermissionAllowed();
    statusCheckAsync();
    driversTodaysEarningsAsync();
    fetchCurrentBalance();
    super.initState();
  }

  // getDirections() async {
  //   List<LatLng> polylineCoordinates = [];

  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       googleMapApiKey,
  //       PointLatLng(startLocation.latitude, startLocation.longitude),
  //       PointLatLng(endLocation.latitude, endLocation.longitude),
  //       travelMode: TravelMode.driving,
  //       wayPoints: [PolylineWayPoint(location: 'Kolkata')]);

  //   if (result.points.isNotEmpty) {
  //     for (var point in result.points) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     }
  //   }
  //   addPolyLine(polylineCoordinates);
  // }

  addPolyLine(List<LatLng> polylineCoordinates) {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        bool backStatus = onWillpop(context);
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: drawer(size),
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
            : isOnline
            ? Stack(
                children: [
                  onlinegoogleMap(),
                      isVerified ? customInfoWindow(size) : const SizedBox(),
                      isVerified ? onlineTopheader() : const SizedBox(),
                      //passangerDetailBottomSheet(size)
                ],
              )
            : Stack(
                children: [
                  googleMap(),
                  currentLoationBox(),
                      isVerified ? goOnlineButton() : const SizedBox(),
                ],
              ),
        //floatingActionButton: isOnline ? null : currentLocationButton(),
      ),
    );
  }

  passangerDetailBottomSheet(ui.Size size) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: BottomSheet(
            enableDrag: false,
            constraints: BoxConstraints(maxHeight: size.height - 100),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            backgroundColor: Colors.transparent,
            onClosing: () {},
            builder: (context) {
              return Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: blackColor.withOpacity(0.25), blurRadius: 6)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    heightSpace,
                    heightSpace,
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    heightSpace,
                    isShowMore
                        ? Expanded(
                            child: passangerDetail(context),
                          )
                        : passangerDetail(context),
                    acceptRejectAndLessMoreButtons(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  acceptRejectAndLessMoreButtons() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/gotoPickup');
            },
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.3),
              color: primaryColor,
              alignment: Alignment.center,
              child: const Text(
                "Accept",
                style: bold18White,
              ),
            ),
          ),
        ),
        widthBox(3),
        Expanded(
          child: InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.3),
              color: primaryColor,
              alignment: Alignment.center,
              child: const Text(
                "Reject",
                style: bold18White,
              ),
            ),
          ),
        ),
        widthBox(3),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                isShowMore = !isShowMore;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.3),
              color: primaryColor,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isShowMore
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: whiteColor,
                  ),
                  width5Space,
                  Text(
                    isShowMore ? "Less" : "More",
                    style: bold18White,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  passangerDetail(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      children: [
        passangerProfileImage(context),
        heightSpace,
        const Text(
          "Tynisha Obey",
          style: semibold17Black,
          textAlign: TextAlign.center,
        ),
        heightSpace,
        rideFareAndDistance(),
        isShowMore
            ? Column(
                children: [
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  titleRowWidget("Trip Route", "10 km (15 min)"),
                  heightSpace,
                  heightSpace,
                  pickupDropLocation(),
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  titleRowWidget("Payments", "\$30.50"),
                  heightSpace,
                  paymentMethod(),
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  const Text(
                    "Other Info",
                    style: bold18Black,
                  ),
                  heightSpace,
                  Row(
                    children: [
                      otherItemWidget("Payment via", "Wallet"),
                      otherItemWidget("Ride fare", "\$30.50"),
                      otherItemWidget("Ride type", "Mini")
                    ],
                  ),
                  heightSpace,
                ],
              )
            : const SizedBox(),
      ],
    );
  }

  otherItemWidget(title, content) {
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
            style: bold15Black,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  paymentMethod() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: lightGreyColor),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/home/wallet.png",
            height: 40,
            width: 40,
          ),
          widthSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "**** **** **56 7896",
                  style: semibold16Black,
                ),
                Text(
                  "Wallet",
                  style: semibold12Grey,
                )
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: secondaryColor)
        ],
      ),
    );
  }

  pickupDropLocation() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: secondaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Text(
                  "9 Bailey Drive, Fredericton, NB E3B 5A3",
                  style: semibold15Black,
                  overflow: TextOverflow.ellipsis,
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
          const Row(
            children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Text(
                  "1655 Island Pkwy, Kamloops, BC V2B 6Y9",
                  style: semibold15Black,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  titleRowWidget(text1, text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text1,
            style: bold18Black,
          ),
        ),
        Text(
          text2,
          style: bold14Primary,
        )
      ],
    );
  }

  rideFareAndDistance() {
    return const Row(
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
                "\$22.50",
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
                "Location distance",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "10km",
                style: semibold15Black,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        )
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
          child: const Icon(
            Icons.call,
            color: primaryColor,
            size: 16,
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
              image: AssetImage("assets/home/passanger.png"),
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
            Navigator.pushNamed(context, '/chat');
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
              CupertinoIcons.ellipses_bubble_fill,
              color: primaryColor,
              size: 16,
            ),
          ),
        )
      ],
    );
  }

  onlineTopheader() {
    return Padding(
      padding: EdgeInsets.only(
          top: (Platform.isIOS) ? fixPadding * 6.0 : fixPadding * 4.0,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
                child: menuButton(whiteColor),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isOnline = !isOnline;
                    _toggleSwitch(isOnline);
                  });
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: fixPadding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: primaryColor,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Go Offline",
                    style: bold18White,
                  ),
                ),
              )
            ],
          ),
          height5Space,
          height5Space,
          height5Space,
          driverAndRideInfo(),
          height5Space,
          height5Space,
          isExpired == true ? expiryAlert() : const SizedBox()

        ],
      ),
    );
  }

  customInfoWindow(Size size) {
    return CustomInfoWindow(
      controller: _customInfoWindowController,
      width: size.width * 0.7,
      height: 40,
      offset: 50,
    );
  }

  onlinegoogleMap() {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow!();
      },
      onCameraMove: (position) {
        _customInfoWindowController.onCameraMove!();
      },
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: currentPosition,
      onMapCreated: mapCreated,
      markers: Set.from(onlineallMarkers),
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  pickUpDropMarker() async {
    onlineallMarkers.add(
      Marker(
        markerId: const MarkerId("drop location"),
        position: endLocation,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ]),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "10km",
                      style: bold10White,
                    ),
                  ),
                  widthSpace,
                  const Expanded(
                    child: Text(
                      "1655 Island Pkwy, Kamloops, BC V2B 6Y9",
                      style: semibold14Black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            endLocation,
          );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/drop.png", 130),
        ),
      ),
    );
    onlineallMarkers.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: startLocation,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: fixPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "9 Bailey Drive, Fredericton, NB E3B 5A3",
                style: semibold14Black,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            startLocation,
          );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/pickup.png", 60),
        ),
      ),
    );
  }

  goOnlineButton() {
    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              isOnline = !isOnline;
              _toggleSwitch(isOnline);
            });
          },
          child: Container(
            height: 110,
            width: 110,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/home/goOnline.png"),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Go\nOnline",
              style: extrabold18White,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  googleMap() {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow!();
      },
      onCameraMove: (position) {
        if (_customInfoWindowController != null)
          _customInfoWindowController.onCameraMove!();
      },
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: currentPosition,
      onMapCreated: mapCreated,
      markers: Set.from(allMarkers),
    );
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;

    _customInfoWindowController.googleMapController = controller;
    await locateUserPosition();
    // await marker();
    // await pickUpDropMarker();
    setState(() {});
  }

  marker() async {
    allMarkers.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: const LatLng(22.566914, 88.357089),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/top - taxi.png", 95),
        ),
      ),
    );
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

  currentLocationButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: FloatingActionButton(
        backgroundColor: whiteColor,
        mini: true,
        onPressed: _goCurrentPosition,
        child: const Icon(
          Icons.my_location,
          color: blackColor,
          size: 20,
        ),
      ),
    );
  }

  _goCurrentPosition() async {
    final GoogleMapController controller = mapController!;
    controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
  }

  currentLoationBox() {
    return Padding(
      padding: const EdgeInsets.only(
          top: fixPadding * 4.0,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (Platform.isIOS)
              ? const SizedBox(height: fixPadding * 2.0)
              : const SizedBox(height: 0, width: 0),
          onlineOfflineBox(),
          heightSpace,
          isVerified ? driverAndRideInfo() : const SizedBox(),
          height5Space,
          isExpired == true ? expiryAlert() : const SizedBox()
        ],
      ),
    );
  }

  driverAndRideInfo() {
    return Container(
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(profilePic),
              ),
            ),
          ),
          widthSpace,
          width5Space,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${todaysRides} Rides | \₹${todaysEarnings.round()}",
                style: bold13White,
              ),
              height5Space,
              const Text(
                "Today",
                style: semibold12White,
              ),
              height5Space,
              Text(
                "Current Balance: \₹${double.parse(currentBalance).round()}",
                style: semibold12White,
              )
            ],
          )
        ],
      ),
    );
  }

  expiryAlert() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, GoodsDriverRechargeHomeRoute);
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding),
        decoration: BoxDecoration(
          color: redColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: const Row(
          children: [
            Icon(
              CupertinoIcons.clock_solid,
              color: Colors.white,
            ),
            widthSpace,
            width5Space,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Plan expired, please recharge.",
                  style: semibold12White,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  onlineOfflineBox() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          expansionTileTheme: const ExpansionTileThemeData(
            collapsedIconColor: primaryColor,
            iconColor: primaryColor,
          ),
        ),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.white,
          title: Row(
            children: [
              menuButton(blackColor),
              widthSpace,
              widthSpace,
              isVerified
                  ? Expanded(
                      child: isOnline ? onlineText() : offlineText(),
                    )
                  : Expanded(child: verifiedStatusText())
            ],
          ),
          childrenPadding:
              const EdgeInsets.only(bottom: fixPadding, top: fixPadding / 2),
          children: [
            isVerified
                ? InkWell(
                    onTap: () {
                      setState(() {
                        isOnline = !isOnline;
                        _toggleSwitch(isOnline);
                      });
                    },
                    child: Container(
                      child: isOnline ? offlineText() : onlineText(),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  verifiedStatusText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: redColor,
          ),
        ),
        widthSpace,
        Text(
          "$verifiedStatus",
          style: semibold12Grey,
        )
      ],
    );
  }

  onlineText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
        ),
        widthSpace,
        const Text(
          "You’re Online",
          style: semibold15Black,
        )
      ],
    );
  }

  offlineText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: redColor,
          ),
        ),
        widthSpace,
        const Text(
          "You’re Offline",
          style: semibold15Black,
        )
      ],
    );
  }

  drawer(Size size) {
    return Row(
      children: [
        Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(20.0),
            ),
          ),
          width: size.width * 0.75,
          backgroundColor: whiteColor,
          child: Column(
            children: [
              userInformation(size),
              drawerItemsList(),
            ],
          ),
        ),
        closeButton(size),
      ],
    );
  }

  userInformation(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 5.0, horizontal: fixPadding * 1.5),
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: size.height * 0.09,
            width: size.height * 0.09,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: size.height * 0.085,
                    width: size.height * 0.085,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          profilePic,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, GoodsDriverEditProfileRoute)
                          .then((value) =>
                              scaffoldKey.currentState?.closeDrawer());
                    },
                    child: Container(
                      height: size.height * 0.038,
                      width: size.height * 0.038,
                      decoration: const BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.border_color_outlined,
                        size: 15,
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${driverName}",
                  style: bold16White,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${mobileNo}",
                  style: regular14White,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  closeButton(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipPath(
          clipper: CustomMenuClipper(),
          child: Container(
            width: size.width * 0.22,
            height: 130,
            decoration: const BoxDecoration(color: whiteColor),
            padding: const EdgeInsets.only(left: fixPadding / 3),
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                if (scaffoldKey.currentState!.isDrawerOpen) {
                  scaffoldKey.currentState!.closeDrawer();
                }
              },
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: greyColor.withOpacity(0.5),
                      blurRadius: 6,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  drawerItemsList() {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        physics: const BouncingScrollPhysics(),
        children: [
          drawerItemWidget(Icons.home_rounded, "Home", () {
            Navigator.pushNamed(context, AgentHomeScreenRoute);
            scaffoldKey.currentState?.closeDrawer();
          }),
          isOnline ? divider() : const SizedBox(),
          isOnline
              ? drawerItemWidget(Icons.location_on_rounded, "Live Ride", () {
                  Navigator.pushNamed(context, NewTripDetailsRoute)
                      .then((value) => scaffoldKey.currentState?.closeDrawer());
                })
              : const SizedBox(),
          divider(),
          drawerItemWidget(Icons.drive_eta, "My Rides", () {
            Navigator.pushNamed(context, GoodsDriverRidesRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.chart_bar_square_fill, "My Earnings",
              () {
            Navigator.pushNamed(context, GoodsDriverEarningsRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.star, "My Ratings", () {
            Navigator.pushNamed(context, GoodsDriverRatingsRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.account_tree_rounded, "Recharge", () {
            Navigator.pushNamed(context, GoodsDriverRechargeHomeRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.history, "Recharge History", () {
            Navigator.pushNamed(context, GoodsDriverRechargeHistoryRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          // divider(),
          // drawerItemWidget(Icons.notifications_sharp, "Notification", () {
          //   Navigator.pushNamed(context, GoodsDriverNotificationRoute)
          //       .then((value) => scaffoldKey.currentState?.closeDrawer());
          // }),
          divider(),
          drawerItemWidget(CupertinoIcons.gift_fill, "Invite Friends", () {
            Navigator.pushNamed(context, GoodsDriverInviteFriendsRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.question_circle_fill, "FAQs", () {
            Navigator.pushNamed(context, GoodsDriverFAQSRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.email, "Contact us", () {
            Navigator.pushNamed(context, GoodsDriverContactUsRoute)
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(
            Icons.logout,
            "Logout",
            () {
              logoutDialog();
            },
          ),
          divider(),
          GestureDetector(
            onTap: () {
              // Navigator.pushNamed(context, CustomerMainScreenRoute)
              //     .then((value) => scaffoldKey.currentState?.closeDrawer());
              Navigator.pushNamedAndRemoveUntil(
                context,
                CustomerMainScreenRoute,
                (route) =>
                    false, // This condition removes all routes from the stack
              ).then((value) => scaffoldKey.currentState?.closeDrawer());
            },
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(fixPadding * 2.0),
                width: size.width * 0.75,
                padding: const EdgeInsets.all(fixPadding * 1.3),
                decoration: BoxDecoration(
                  color: primaryColor,
                  boxShadow: buttonShadow,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: const Text(
                  "Switch as Customer",
                  style: bold12White,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )

          // drawerItemWidget(
          //   Icons.person_3,
          //   "Switch as a Customer",
          //   () {
          //     Navigator.pushNamed(context, CustomerMainScreenRoute)
          //         .then((value) => scaffoldKey.currentState?.closeDrawer());
          //   },
          // ),
        ],
      ),
    );
  }


  drawerItemWidget(IconData icon, String title, Function() onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 6))
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: whiteColor,
          size: 16,
        ),
      ),
      minLeadingWidth: 0,
      title: Text(
        title,
        style: bold17Black,
      ),
    );
  }

  logoutDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          insetPadding: const EdgeInsets.all(fixPadding * 2.0),
          contentPadding: const EdgeInsets.all(fixPadding * 2.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.question_circle_fill,
                    color: primaryColor,
                  ),
                  widthSpace,
                  Expanded(
                    child: Text(
                      "Do You Want to Logout...?",
                      style: semibold16Black,
                    ),
                  )
                ],
              ),
              heightSpace,
              heightSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding, horizontal: fixPadding * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: greyShade3),
                        color: whiteColor,
                      ),
                      child: const Text(
                        "Cancel",
                        style: bold16Grey,
                      ),
                    ),
                  ),
                  widthSpace,
                  InkWell(
                    onTap: () {
                      logoutNowAsync();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding, horizontal: fixPadding * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: buttonShadow,
                        color: primaryColor,
                      ),
                      child: const Text(
                        "Logout",
                        style: bold16White,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> logoutNowAsync() async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString("goods_driver_id", "");

    Navigator.pushNamedAndRemoveUntil(
      context,
      CustomerMainScreenRoute,
      (Route<dynamic> route) => false, // Removes all previous routes
    );
  }

  divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: fixPadding / 4),
      width: double.maxFinite,
      color: lightGreyColor,
    );
  }

  menuButton(Color color) {
    return InkWell(
      onTap: () {
        scaffoldKey.currentState?.openDrawer();
      },
      child: Icon(
        Icons.notes,
        color: color,
      ),
    );
  }

  onWillpop(context) {
    DateTime now = DateTime.now();
    if (backpressTime == null ||
        now.difference(backpressTime!) >= const Duration(seconds: 2)) {
      backpressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: blackColor,
          content: Text(
            "Press back once again to exit",
            style: bold15White,
          ),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 10, 10, 19);
    path.conicTo(width, height / 2, 5, height - 18, 1.0);
    path.conicTo(0, height - 12, 0, height, 1.4);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
