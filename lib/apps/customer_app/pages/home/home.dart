import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/apps/widgets/column_builder.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/active_nearby_goods_drivers.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/push_notifications/notification_service.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? backpressTime;

  String _address = "Loading...";

  Position? userCurrentPosition;

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  double bottomPaddingOfMap = 0.0;

  AppInfo? appInfo;

  bool _isServiceAvailable = false,
      isLoading = true,
      _locationInitialized = false;

  Set<Marker> markersSet = {};

  Set<Circle> circlesSet = {};

  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearByGoodsDrivers> activeNearByGoodsDrivers = [];

  Position? customersCurrentPosition;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late CameraPosition _currentPosition;

  final placeList = [
    {
      "name": "Bailey Drive, Fredericton",
      "address": "9 Bailey Drive, Fredericton, NB E3B 5A3"
    },
    {
      "name": "Belleville St, Victoria",
      "address": "225 Belleville St, Victoria, BC V8V 1X1"
    },
  ];

  GoogleMapController? mapController;

  bool _showBottomSheet = true;

  Timer? _debounce;

  double _latitude = 0.0;

  double _longitude = 0.0;

  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(37.9826161, -122.0323782),
    zoom: 14.00,
    bearing: 40,
  );

  List<Marker> allMarkers = [];

  String _customer_name = "";

  late LatLng _userLocation;

  List cabMarkers = [
    {
      "image": "assets/home/cab1.png",
      "latLng": const LatLng(37.9826161, -122.0323782),
      "id": "cab1",
      "size": 100
    },
    {
      "image": "assets/home/cab2.png",
      "latLng": const LatLng(37.9901, -122.0390),
      "id": "cab2",
      "size": 70
    },
    {
      "image": "assets/home/cab3.png",
      "latLng": const LatLng(37.9836, -122.0451),
      "id": "cab3",
      "size": 95
    },
    {
      "image": "assets/home/cab4.png",
      "latLng": const LatLng(37.9870, -122.0209),
      "id": "cab4",
      "size": 80
    },
    {
      "image": "assets/home/cab5.png",
      "latLng": const LatLng(37.9971, -122.0329),
      "id": "cab5",
      "size": 100
    }
  ];

  NotificationService notificationService = NotificationService();

  Future<void> getNotificationToken() async {
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.isTokenRefreshed();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    final pref = await SharedPreferences.getInstance();
    pref.setString("device_token", "");
    pref.setBool("openCustomer", true);
    pref.setBool("openDriver", false);
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
      var token = await notificationService.getDeviceToken();
      pref.setString("device_token", token);
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getDistanceAndTime(List<ActiveNearByGoodsDrivers> drivers,
      double pickupLat, double pickupLng) async {
    final apiKey = mapKey;
    for (var driver in drivers) {
      final url =
          'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${driver.locationLatitude},${driver.locationLongitude}&destinations=$pickupLat,$pickupLng&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['rows'][0]['elements'][0]['status'] == 'OK') {
            driver.arrivalDistance =
                data['rows'][0]['elements'][0]['distance']['text'];
            driver.arrivalTime =
                data['rows'][0]['elements'][0]['duration']['text'];

            print("Distance: ${driver.arrivalDistance}");
            print("Estimated Time: ${driver.arrivalTime}");
          }
        } else {
          print("Failed to load data: ${response.statusCode}");
        }
      } catch (e) {
        print("Error: $e");
      }
    }

    setState(() {
      isLoading = false;
      // showError = false;
    });
    // Update state
    setState(() {
      activeNearByGoodsDrivers = drivers;
    });
  }

  Future<void> getOnlineGoodsDrivers() async {
    print("getting online drivers vehicle details");
    final pref = await SharedPreferences.getInstance();
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userCurrentLocation?.locationLatitude;
    var longitude = appInfo.userCurrentLocation?.locationLongitude;

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
      isLoading = true;
      activeNearByGoodsDrivers = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_nearby_drivers', data);
      if (kDebugMode) {
        print(response);
      }
      final appInfo = Provider.of<AppInfo>(context, listen: false);

      var nearbyDrivers = response['nearby_drivers'];

      // Check if the response contains 'results' key and parse it
      if (nearbyDrivers != null && nearbyDrivers.isNotEmpty) {
        List<dynamic> servicesData = response['nearby_drivers'];
        List<ActiveNearByGoodsDrivers> drivers = servicesData
            .map(
                (serviceJson) => ActiveNearByGoodsDrivers.fromJson(serviceJson))
            .toList();
        // Fetch distance and arrival time for each driver
        await getDistanceAndTime(drivers, latitude!, longitude!);

        displayActiveDriversOnUsersMap();
      } else {
        print("show error here");
        setState(() {
          //showError = true;
          activeNearByGoodsDrivers = [];
        });
        glb.showToast("No drivers found nearby. Please try again later.");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        //showError = true;
      });
      if (e.toString().contains("No Data Found")) {
        glb.showToast(
            "No Drivers Found in your location try to refresh and search again.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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

    driversMarkerSet.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: LatLng(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/pickup_Location.png", 200),
        ),
      ),
    );

    setState(() {
      markersSet = driversMarkerSet;
    });
  }

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
        getOnlineGoodsDrivers();
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

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    if (mapController != null) {
      mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
    setState(() {});
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // notificationService.requestNotificationPermission();
    getNotificationToken();
    checkServiceAvailable();
    //getOnlineGoodsDrivers();

    checkIfLocationPermissionAllowed();
    _getUserLocationAndAddress();
    _currentPosition = currentPosition;
    print("init pickup location map");
    _setUserLocationMarker(context);
    _resetLocations();
    //updateDriversLocationAtRealTime();
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
        body: Stack(
          children: [
            googleMap(),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: currentLocationBox(context),
            ),
            whereToGoBottomSheet(size),
          ],
        ),
      ),
    );
  }

  currentLocationButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: fixPadding, right: fixPadding),
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
      ),
    );
  }

  googleMap() {
    return GoogleMap(
      padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
      zoomControlsEnabled: true,
      myLocationEnabled: true,
      mapType: MapType.terrain,
      initialCameraPosition: currentPosition,
      onMapCreated: mapCreated,
      onCameraMove: onCameraMove,
      markers: markersSet,
    );
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    // await marker();
    _controller.complete(controller);
    setState(() {
      bottomPaddingOfMap = 150.0;
    });
    locateUserPosition();
    setState(() {});
  }

  marker() async {
    allMarkers.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: const LatLng(37.9894, -122.0242),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/pickup_Location.png", 130),
        ),
      ),
    );
    for (int i = 0; i < cabMarkers.length; i++) {
      allMarkers.add(
        Marker(
          markerId: MarkerId(cabMarkers[i]['id'].toString()),
          position: cabMarkers[i]['latLng'] as LatLng,
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset(
                cabMarkers[i]['image'], cabMarkers[i]['size']),
          ),
        ),
      );
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

  _goCurrentPosition() async {
    locateUserPosition();
    // final GoogleMapController controller = mapController!;
    // controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
  }

  currentLocationBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          top: fixPadding * 4.0,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0),
      padding: const EdgeInsets.symmetric(
        vertical: fixPadding * 1.5,
        horizontal: fixPadding,
      ),
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
      child: Row(
        children: [
          InkWell(
            onTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
            child: const Icon(
              Icons.notes,
              color: blackColor,
            ),
          ),
          widthSpace,
          widthSpace,
          Expanded(
            child: Row(
              children: [
                // Icon(
                //   Icons.place_rounded,
                //   color: primaryColor,
                //   size: 20,
                // ),
                // width5Space,
                Expanded(
                  child: Text(
                    Provider.of<AppInfo>(context).userCurrentLocation != null
                        ? Provider.of<AppInfo>(context)
                            .userCurrentLocation!
                            .locationName!
                        : "Loading ...", //Current Location
                    style: semibold12Grey,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
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
              drawerItems(),
            ],
          ),
        ),
        closeButton(size),
      ],
    );
  }

  whereToGoBottomSheet(size) {
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
            constraints: BoxConstraints(maxHeight: size.height * 0.6),
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            onClosing: () {},
            builder: (context) {
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  //currentLocationButton(),
                  Container(
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
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: fixPadding * 2.0, vertical: fixPadding),
                      physics: const BouncingScrollPhysics(),
                      children: [
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
                        heightSpace,
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/pickUpLocation');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: fixPadding),
                            width: double.maxFinite,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: greyF0Color,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  CupertinoIcons.search,
                                  color: primaryColor,
                                  size: 22,
                                ),
                                widthSpace,
                                width5Space,
                                Expanded(
                                  child: Text(
                                    "What service would you like to explore?",
                                    style: semibold15Black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        heightSpace,
                        heightSpace,
                        heightSpace,
                        heightSpace,
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/home/User.png",
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
                      Navigator.pushNamed(context, '/editProfile').then(
                          (value) => scaffoldKey.currentState?.closeDrawer());
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
                        Icons.border_color,
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Samantha Smith",
                  style: bold16White,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "samanthasmith@gmail.com",
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
            decoration: const BoxDecoration(
              color: whiteColor,
            ),
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

  drawerItems() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        physics: const BouncingScrollPhysics(),
        children: [
          drawerItemWidget(Icons.home_rounded, "Home", () {
            scaffoldKey.currentState!.closeDrawer();
          }),
          divider(),
          drawerItemWidget(Icons.drive_eta, "My Rides", () {
            Navigator.pushNamed(context, '/myride')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.account_balance_wallet_rounded, "Wallet", () {
            Navigator.pushNamed(context, '/wallet')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.notifications_sharp, "Notification", () {
            Navigator.pushNamed(context, '/notification')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.gift_fill, "Invite Friends", () {
            Navigator.pushNamed(context, '/invitefriends')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.question_circle_fill, "FAQs", () {
            Navigator.pushNamed(context, '/faqs')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.email, "Contact us", () {
            Navigator.pushNamed(context, '/contactUs')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(
            Icons.logout,
            "Logout",
            () {
              logoutDialog();
            },
          ),
        ],
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
                      Navigator.pushNamed(context, CustomerLoginRoute);
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

  divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: fixPadding / 4),
      width: double.maxFinite,
      color: lightGreyColor,
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
    _debounce?.cancel();
    mapController!.dispose();
    Future.delayed(const Duration(milliseconds: 2000), () {
      glb.streamSubscriptionPosition?.cancel();
      // MyApp.restartApp(context);
    });
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
