import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/delivery_agent_pages/helpers/settings_menu_agent.dart';
import 'package:vt_partner/global/global.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/push_notifications/notification_service.dart';
import 'package:vt_partner/push_notifications/push_notification_system.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/services/notification_service.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:http/http.dart' as http;
import 'package:vt_partner/widgets/shimmer_card.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;
//15.892953, 74.518013
bool isLoading = true;
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

  Position? driverCurrentPosition;

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  Set<Marker> markersSet = {};
  BitmapDescriptor? customMarkerIcon;

  double bottomPaddingOfMap = 0.0;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    if (newGoogleMapController != null) {
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

    // Add custom marker at the user's current location
    Marker userMarker = Marker(
      markerId: MarkerId("currentLocation"),
      position: latLngPosition,
      icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: "You are here"),
    );

    setState(() {
      markersSet.add(userMarker);
    });
  }

  // Set custom marker icon for the user's location
  void setCustomMarkerIcon() async {
    customMarkerIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      'assets/icons/3d_location.png', // Replace with your own marker asset
    );
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  bool isVerified = false;
  String driverName = "", verifiedStatus = "";
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
          driverName = ret["driver_first_name"].toString().split(' ')[0];
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
        Navigator.pop(context);
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

  Future<void> _handleRefresh() async {
    Future.delayed(const Duration(milliseconds: 1000), () {
      streamSubscriptionPosition?.cancel();
      // MyApp.restartApp(context);
    });
    getNotificationToken();
    _setupCameraController();
    setCustomMarkerIcon();
    checkIfLocationPermissionAllowed();
    statusCheckAsync();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      streamSubscriptionPosition?.cancel();
      // MyApp.restartApp(context);
    });
    getNotificationToken();
    _setupCameraController();
    setCustomMarkerIcon();
    checkIfLocationPermissionAllowed();
    statusCheckAsync();

  }

  // Stop location updates and clean up when screen is disposed
  @override
  void dispose() async {
    // Cancel the position stream subscription
    if (newGoogleMapController != null) {
    newGoogleMapController?.dispose();
    }
    
    
    super.dispose();
  }

  double searchLocationContainerHeight = 220.0;
  bool isOnline = false; // Default state

  void _toggleSwitch(bool value) {
    // Show confirmation dialog before toggling
    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Change Status'),
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
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Confirm',
                style: nunitoSansStyle.copyWith(
                    color: isOnline ? Colors.red : Colors.green),
              ),
              onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
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
          : Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: _height,
                child: GoogleMap(
                  padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                  mapType: MapType.normal,
                  myLocationEnabled: true, // Disable default blue dot
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  markers: markersSet, // Add custom markers here
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    setState(() {
                      newGoogleMapController = controller;
                    });
                    //For Black Theme Google Map
                    //blackThemeController();
      
                    setState(() {
                      bottomPaddingOfMap = 10;
                    });
                    //Get Users Current Location
                    locateUserPosition();
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0)),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: isVerified
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () {
                                  //Show Drawer screen here
                                        // Scaffold.of(context).openDrawer();
                                  Navigator.pushNamed(
                                      context, AgentSettingsRoute);
                                },
                                icon: Icon(
                                  Icons.menu_outlined,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Ink(
                                width: _width - 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Hello, ${driverName}",
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16.5),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              isVerified
                                  ? Switch(
                                      value: isOnline &&
                                          previousSelfie != null &&
                                          previousSelfie!.isNotEmpty,
                                      onChanged: _toggleSwitch,
                                      activeColor: Colors
                                          .green, // Color when switch is on
                                      inactiveThumbColor: Colors
                                          .red, // Color when switch is off
                                    )
                                  : SizedBox()
                            ],
                          ),
                        ),
                      ),
                      isVerified == true
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0)),
                                  color: isOnline &&
                                          previousSelfie != null &&
                                          previousSelfie!.isNotEmpty
                                      ? Colors.green
                                      : Colors.red),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Ink(
                                      width: _width - 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isOnline &&
                                                        previousSelfie !=
                                                            null &&
                                                        previousSelfie!
                                                            .isNotEmpty
                                                    ? Icons.login
                                                    : Icons.logout,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                isOnline &&
                                                        previousSelfie !=
                                                            null &&
                                                        previousSelfie!
                                                            .isNotEmpty
                                                    ? "You are Online Now"
                                                    : "You are Offline Now",
                                                style: nunitoSansStyle.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 14.5),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0)),
                                  color: isOnline ? Colors.green : Colors.red),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Ink(
                                      width: _width - 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.verified,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                verifiedStatus,
                                                style: nunitoSansStyle.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 14.5),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                   
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  // updateDriversLocationAtRealTime() {
  //   LatLng? oldLatLng;
  //   print("isOnline::$isOnline");
  //   if (isOnline == false) {
  //     Future.delayed(const Duration(milliseconds: 1000), () {
  //       streamSubscriptionPosition?.cancel();
  //       // MyApp.restartApp(context);
  //     });
  //     return;
  //   }
  //   streamSubscriptionPosition =
  //       Geolocator.getPositionStream().listen((Position position) {

  //     driverCurrentPosition = position;
  //     if (isOnline == true) {
  //       // Geofire.setLocation(driverID, driverCurrentPosition!.latitude,
  //       //     driverCurrentPosition!.longitude); // this is used for firebase realtime database
  //       // Update in table also
  //     }

  //     LatLng latLng = LatLng(
  //         driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  //     var latitude = driverCurrentPosition!.latitude;
  //     var longitude = driverCurrentPosition!.longitude;
  //     print("driver cur_lat::$latitude");
  //     print("driver cur_lng::$longitude");
  //     if (isOnline == true) {
  //     Future.delayed(const Duration(milliseconds: 2000), () {
  //       updateDriversCurrentPosition(latitude, longitude);
  //       // MyApp.restartApp(context);
  //     });
  //     }
  //     //setState(() {
  //     // print("isOnline::$isOnline");
  //     if (isOnline == false) {
  //       updateDriverStatusAsync(latitude, longitude);
  //     }
  //     //});

  //     if (newGoogleMapController != null) {
  //       newGoogleMapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  //     }

  //   });

  // }

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
          if (newGoogleMapController != null) {
            newGoogleMapController
                ?.animateCamera(CameraUpdate.newLatLng(latLng));
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


updateDriversCurrentPosition(var latitude, var longitude) async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_previous_lat = pref.getDouble("goods_driver_current_lat");
    var goods_driver_previous_lng = pref.getDouble("goods_driver_current_lng");
    var goods_driver_id = pref.getString("goods_driver_id");

    //To avoid multiple entries for same lat lng
    if (goods_driver_previous_lat != null &&
        goods_driver_previous_lat == latitude &&
        goods_driver_previous_lng != null &&
        goods_driver_previous_lng == longitude) {
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
              SizedBox(height: 10),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: IconButton(
                    onPressed: () async {
                      try {
                        XFile picture = await cameraController!.takePicture();
                        // Navigator.of(context).pop(); // Close the dialog
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
                    icon: Icon(
                      Icons.camera,
                      color: Colors.red,
                      size: 60,
                    )),
              ),
            ],
          ),
        );
      },
    );
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

}
