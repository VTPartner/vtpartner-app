import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/geofire_assistant.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/methods/push_notification_service.dart';
import 'package:vt_partner/customer_pages/models/active_nearby_goods_drivers.dart';
import 'package:vt_partner/customer_pages/screens/contacts_screens/contact_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/locate_on_map_screen.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/models/all_services_model.dart';
import 'package:vt_partner/push_notifications/fcm_service.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/push_notifications/notification_service.dart';
import 'package:vt_partner/push_notifications/send_notification_service.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/services/notification_service.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'dart:async';
import 'package:vt_partner/global/global.dart' as glb;
import '../../../../utils/app_styles.dart';
import '../../../../widgets/body_text1.dart';
import '../../../../widgets/description_text.dart';
import '../../../../widgets/dotted_vertical_divider.dart';
import '../../../../widgets/sub_title_text.dart';


class HomeScreenTabPage extends StatefulWidget {
  const HomeScreenTabPage({super.key});

  @override
  State<HomeScreenTabPage> createState() => _HomeScreenTabPageState();
}

class _HomeScreenTabPageState extends State<HomeScreenTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  bool _isMapControllerSet = false;

  GoogleMapController? newGoogleMapController;
//15.892953, 74.518013
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 54.4746,
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
        CameraPosition(target: latLngPosition, zoom: 4);

    if (newGoogleMapController != null) {
      newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  Future<void> _getUserLocationAndAddress() async {
    print("obtain address");
    try {
      Position position = await getUserCurrentLocation();
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoOrdinates(
              position!, context, false);
      print("MyHomeLocation::" + humanReadableAddress);
    } catch (e) {
      setState(() {
        _address = "Error: ${e.toString()}";
      });
    }
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error:::" + error.toString());
    });

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String _address = "Loading...";
  AppInfo? appInfo;

  double searchLocationContainerHeight = 220.0;
  var isServiceProvided = true;
  late CameraPosition _currentPosition;
  late LatLng _userLocation;
  bool _locationInitialized = false;
  String placeId = "";
  final Completer<GoogleMapController> _controller = Completer();
  bool _showBottomSheet = true;
  bool isLoading = false; // To track the loading state
  Timer? _debounce;
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _customer_name = "";
  List<AllServicesModal> allServicesModel = [];
  List<ActiveNearByGoodsDrivers> activeNearByGoodsDrivers = [];
  Position? customersCurrentPosition;

  Future<void> _setUserLocationMarker(context) async {
    final pref = await SharedPreferences.getInstance();
    var customer_name = pref?.getString('customer_name');
    if (customer_name != null) {
      _customer_name = customer_name.split(' ')[0];
    }
    getUserCurrentLocation().then((value) async {
      if (appInfo?.userPickupLocation != null) {
        var locationLatitude = appInfo?.userPickupLocation!.locationLatitude;
        var locationLongitude = appInfo?.userPickupLocation!.locationLongitude;
        print("locationLng::$locationLongitude");
        final userLocation = LatLng(locationLatitude!, locationLongitude!);
        setState(() {
          _userLocation = userLocation;
          _locationInitialized = true;
          _currentPosition = CameraPosition(
            target: _userLocation,
            zoom: 90.0,
          );
        });
        CameraPosition cameraPosition = CameraPosition(
            target: LatLng(locationLatitude, locationLongitude), zoom: 90.0);

        final GoogleMapController controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setState(() {});
        return;
      }

      print(value.latitude.toString() + " " + value.longitude.toString());
      final userLocation = LatLng(value.latitude, value.longitude);
      setState(() {
        _userLocation = userLocation;
        _currentPosition = CameraPosition(
          target: _userLocation,
          zoom: 90.0,
        );
        _locationInitialized = true;
      });

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: 90.0);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      setState(() {});
    });
  }

  onCameraMove(CameraPosition? position) {
    if (position != null) {
      _latitude = position.target.latitude;
      _longitude = position.target.longitude;

      // Cancel any ongoing debounce calls
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      // Set up a new debounce call
      _debounce = Timer(Duration(seconds: 1), () {
        // getAddressFromLatLng(_latitude, _longitude);
        setState(() {
          _showBottomSheet =
              true; // Show the bottom sheet when position is updated
          isLoading = false;
        });
      });

      // Hide bottom sheet when user moves the marker
      if (_showBottomSheet) {
        setState(() {
          _showBottomSheet = false;
          isLoading = true;
        });
      }
    }
  }

  Future<void> fetchAllServices() async {
// final data = {
//       'mobile_no': "+91${glb.customer_mobile_no}",
//     };

    // final pref = await SharedPreferences.getInstance();
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var address = appInfo.userCurrentLocation?.locationName;
    if (address == null || address.isEmpty) {
      MyApp.restartApp(context);
      // return;
    }
    setState(() {
      _showBottomSheet = false;
      allServicesModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/all_services', {});
      if (kDebugMode) {
        // print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> servicesData = response['results'];
        // Map the list of service data into a list of Service objects
        setState(() {
          allServicesModel = servicesData
              .map((serviceJson) => AllServicesModal.fromJson(serviceJson))
              .toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Services Found.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    }
  }

  updateDriversLocationAtRealTime() {
    glb.streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) async {
      customersCurrentPosition = position;
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoOrdinates(
              customersCurrentPosition!, context, false);
      print("MyHomeLocation::" + humanReadableAddress);
      //if (isOnline == true) {
      // Geofire.setLocation(driverID, customersCurrentPosition!.latitude,
      //     customersCurrentPosition!.longitude); // this is used for firebase realtime database
      // Update in table also
      //}

      LatLng latLng = LatLng(customersCurrentPosition!.latitude,
          customersCurrentPosition!.longitude);
      var latitude = customersCurrentPosition!.latitude;
      var longitude = customersCurrentPosition!.longitude;
      print("customers cur_lat::$latitude");
      print("customers cur_lng::$longitude");

      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    });
  }

  bool _isServiceAvailable = false;

  Future<void> checkServiceAvailable() async {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userCurrentLocation?.locationLatitude;
    var longitude = appInfo.userCurrentLocation?.locationLongitude;
    var full_address = appInfo.userCurrentLocation?.locationName;
    var pincode = appInfo.userCurrentLocation?.pinCode;
    if (full_address == null) {
      MyApp.restartApp(context);
    }
    final data = {'pincode': pincode};

    final pref = await SharedPreferences.getInstance();

    setState(() {
      _isServiceAvailable = false;
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/allowed_pin_code', data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        await pref.setString(
            "current_city_id", response["results"][0]["city_id"].toString());
        setState(() {
          _isServiceAvailable = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        //glb.showToast("No Services Found.");
        setState(() {
          _isServiceAvailable = false;
        });
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    }
  }

  Future<void> getOnlineGoodsDrivers() async {
    print("getting online drivers");
    final pref = await SharedPreferences.getInstance();
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userCurrentLocation?.locationLatitude;
    var longitude = appInfo.userCurrentLocation?.locationLongitude;
    var full_address = appInfo.userCurrentLocation?.locationName;
    var pincode = appInfo.userCurrentLocation?.pinCode;

    var city_id = pref.getString("current_city_id");

    final data = {
      'lat': latitude,
      'lng': longitude,
      'city_id': city_id,
      'price_type': 1,
      'radius_km': 3,
    };

    print("current_online_drivers::$data");

    setState(() {
      _showBottomSheet = false;
      activeNearByGoodsDrivers = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_nearby_drivers', data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['nearby_drivers'] != null) {
        List<dynamic> servicesData = response['nearby_drivers'];
        // Map the list of service data into a list of Service objects
        setState(() {
          activeNearByGoodsDrivers = servicesData
              .map((serviceJson) =>
                  ActiveNearByGoodsDrivers.fromJson(serviceJson))
              .toList();
          displayActiveDriversOnUsersMap();
        });
      } else {
        glb.showToast("No Active Driver in your current location");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Services Found.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    }
  }

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  BitmapDescriptor? activeNearbyIcon;

  Future<void> displayActiveDriversOnUsersMap() async {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();
      createMarkers(driversMarkerSet);
    });
  }

  Future<void> createMarkers(driversMarkerSet) async {
    for (ActiveNearByGoodsDrivers eachDriver in activeNearByGoodsDrivers) {
      print("eachDriver::${eachDriver.locationLongitude}");
      LatLng eachDriverActivePosition =
          LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);
      BitmapDescriptor customIcon =
          await glb.getMarkerIconFromUrl(eachDriver.vehicleImage!);
      Marker marker = Marker(
        markerId: MarkerId("driver" + eachDriver.driverId.toString()),
        position: eachDriverActivePosition,
        // icon: activeNearbyIcon!,
        icon: customIcon,
        rotation: 360,
      );
      print("marker::$marker");
      driversMarkerSet.add(marker);
    }

    setState(() {
      markersSet = driversMarkerSet;
    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/vtp_partner_truck.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  NotificationService notificationService = NotificationService();

  Future<void> getNotificationToken() async {
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.isTokenRefreshed();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    final pref = await SharedPreferences.getInstance();
    GetServerKey getServerKey = GetServerKey();
    String accessToken = await getServerKey.getServerKeyToken();
    print("serverKeyToken::$accessToken");
    pref.setString("serverKey", accessToken);

    var device_token = pref.getString("device_token");
    if (device_token == null || device_token.isEmpty) {
      await notificationService.getDeviceToken();
      updateCustomerAuthToken();
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

  Future<void> updateCustomerAuthToken() async {
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
    var deviceToken = pref.getString("device_token");
    var customer_id = pref.getString("customer_id");
    if (deviceToken == null || deviceToken.isEmpty) {
      notificationService.getDeviceToken();
      updateCustomerAuthToken();
      return;
    }
    final data = {'customer_id': customer_id, 'authToken': deviceToken};

    setState(() {
      _isServiceAvailable = false;
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/update_firebase_customer_token', data);
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

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // notificationService.requestNotificationPermission();
    getNotificationToken();
    checkServiceAvailable();
    getOnlineGoodsDrivers();

    fetchAllServices();
    checkIfLocationPermissionAllowed();
    _getUserLocationAndAddress();
    _currentPosition = _kGooglePlex;
    print("init pickup location map");
    _setUserLocationMarker(context);
    _resetLocations();
    //updateDriversLocationAtRealTime();
  }

  _resetLocations() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString("sender_name", "");
    pref.setString("sender_number", "");
    pref.setString("receiver_name", "");
    pref.setString("receiver_number", "");
    pref.setString("pickup_city_id", "");

    Provider.of<AppInfo>(context, listen: false)
        .updateDropOfLocationAddress(null);
    Provider.of<AppInfo>(context, listen: false)
        .updatePickupLocationAddress(null);
    Provider.of<AppInfo>(context, listen: false)
        .updateSenderContactDetails(null);
    Provider.of<AppInfo>(context, listen: false)
        .updateReceiverContactDetails(null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    newGoogleMapController?.dispose();
    Future.delayed(const Duration(milliseconds: 2000), () {
      glb.streamSubscriptionPosition?.cancel();
      // MyApp.restartApp(context);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();
    appInfo = Provider.of<AppInfo>(context);

    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: ThemeClass.backgroundColorLightPink,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: ThemeClass.facebookBlue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.network(
                          "https://vtpartner.in/media/image_YoRjcDi.jpg",
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome ${_customer_name} 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_history),
                title: Text('Switch As Goods Agent'),
                onTap: () {
                  navigateToGoodsDriver();
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.car_repair_rounded),
              //   title: Text('Switch As Cab Driver'),
              //   onTap: () {
              //     // Navigator.pushNamed(context, HistoryScreenRoute);
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.hail_outlined),
              //   title: Text('Switch As Driver'),
              //   onTap: () {
              //     // Navigator.pushNamed(context, SettingsScreenRoute);
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.person_pin_circle),
              //   title: Text('Switch As HandyMan'),
              //   onTap: () {
              //     // Navigator.pushNamed(context, SettingsScreenRoute);
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.logout),
              //   title: Text('Logout'),
              //   onTap: () {
              //     // Add your logout logic here
              //   },
              // ),
            ],
          ),
        ),
        body: _locationInitialized == false
            ? Center(
                child: CircularProgressIndicator(
                  color: ThemeClass.facebookBlue,
                ),
              )
            : SafeArea(
                top: false,
                bottom: true,
                child: Stack(
                  children: [
                    GoogleMap(
                      padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                      initialCameraPosition: _currentPosition,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      buildingsEnabled: true,
                      zoomControlsEnabled: true,
                      markers: markersSet,
                      circles: circlesSet,
                      onCameraMove: onCameraMove,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        setState(() {
                          bottomPaddingOfMap = 210.0;
                        });
                        locateUserPosition();
                      },
                    ),
                    // if (_locationInitialized)
                    //   Positioned(
                    //     left: MediaQuery.of(context).size.width / 2 -
                    //         16, // Center horizontally
                    //     top: MediaQuery.of(context).size.height / 1 -
                    //         2.5, // Center vertically
                    //     child: SvgPicture.asset(
                    //       "assets/svg/blue_pin.svg",
                    //       // color: Colors.green[600],
                    //       width: 45,
                    //       height: 45,
                    //     ),
                    //   ),
                    _showBottomSheet
                        ? Positioned(
                            left: 0,
                            right: 0,
                            top: MediaQuery.of(context).size.height / 2 -
                                65, // Adjust for tooltip position
                            child:
                                CustomTooltip(message: "")) //Current Location
                        : SizedBox(),
                    Positioned(
                      top: 0,
                      left: 10,
                      right: 20,
                      child: SafeArea(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.3), // Shadow color
                                offset: Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              children: [
                                Builder(builder: (BuildContext context) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: IconButton(
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                        icon: Icon(
                                          Icons.menu,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                           
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(2.0),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, PickUpAddressRoute);
                                    },
                                    child: Ink(
                                      width: _width - 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Your Current Location",
                                            style: nunitoSansStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                                fontSize: 11.5),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            Provider.of<AppInfo>(context)
                                                        .userCurrentLocation !=
                                                    null
                                                ? Provider.of<AppInfo>(context)
                                                    .userCurrentLocation!
                                                    .locationName!
                                                : "Loading ...",
                                            style: nunitoSansStyle.copyWith(
                                                color: Colors.grey[800],
                                                fontSize: 11.5),
                                            overflow: TextOverflow.ellipsis,
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
                      ),
                    ),
                  ],
                ),
              ),
        bottomSheet: _showBottomSheet
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Shadow color
                      offset: Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Our Services",
                                style: nunitoSansStyle.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize),
                                        
                                overflow: TextOverflow.visible,
                    ),
                    SizedBox(
                      height: kHeight - 10,
                    ),
                    Container(
                      
                      height: 120,
                      child: ListView.builder(
                        itemCount: allServicesModel.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              var category_id =
                                  allServicesModel[index].categoryId;
                              if (category_id == 1)
                                Navigator.pushNamed(context,
                                    PickUpAndDropBookingLocationsRoute);
                            },
                            child: Column(
                              children: [
                                              
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                        color:
                                            ThemeClass.backgroundColorLightPink,
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                        allServicesModel[index].categoryImage,
                                        fit: BoxFit.contain,
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: kHeight - 10,
                                ),
                                Text(
                                  allServicesModel[index].categoryName,
                                  style: nunitoSansStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: kHeight),
                  ],
                ),
              )
            : null);
  }

  void navigateToGoodsDriver() async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");
    var driver_name = pref.getString("driver_name");
    if (goods_driver_id != null &&
        driver_name != null &&
        goods_driver_id.isNotEmpty &&
        driver_name.isNotEmpty &&
        driver_name != "NA") {
      // Future.delayed(const Duration(milliseconds: 100), () {
      //   glb.streamSubscriptionPosition?.cancel();
      //   // MyApp.restartApp(context);
      // });
      Navigator.pop(context);
      Navigator.pushNamed(context, AgentHomeScreenRoute);
    } else {
      // Future.delayed(const Duration(milliseconds: 100), () {
      //   glb.streamSubscriptionPosition?.cancel();
      //   // MyApp.restartApp(context);
      // });
      Navigator.pop(context);
      Navigator.pushNamed(context, AgentLoginRoute);
    }
    //goods_driver_id,driver_name
  }

}
