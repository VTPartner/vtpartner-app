import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/locate_on_map_screen.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';

class CabUserPickupLocateOnMapScreen extends StatefulWidget {
  const CabUserPickupLocateOnMapScreen({super.key});

  @override
  State<CabUserPickupLocateOnMapScreen> createState() =>
      _CabUserPickupLocateOnMapScreenState();
}

class _CabUserPickupLocateOnMapScreenState
    extends State<CabUserPickupLocateOnMapScreen> {
  bool _isChecked = false;
  bool _showBottomSheet = true;
  TextEditingController senderNameController = TextEditingController();
  TextEditingController senderNumberController = TextEditingController();

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 110,
  );

  var _address = "";
  bool isLoading = false; // To track the loading state
  Timer? _debounce;

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    setState(() {
      isLoading = true; // Start loading when camera moves
    });
    try {
      String humanReadableAddress =
          await AssistantMethods.mapLocationUsingFromLatLng(lat, lng, context);
      // print("New Pickup Location::$humanReadableAddress");
      if (humanReadableAddress.isNotEmpty) {
        setState(() {
          isLoading = false; // Stop loading when address is found
        });
      } else {
        setState(() {
          _address = "";
          isLoading = false; // Stop loading even if no address is found
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  late CameraPosition _currentPosition;
  late LatLng _userLocation;
  bool _locationInitialized = false;
  String placeId = "";
  AppInfo? appInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access the inherited widget here
    appInfo = Provider.of<AppInfo?>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _currentPosition = _kGooglePlex;
    print("init pickup location map");
    _setUserLocationMarker(context);
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error:::" + error.toString());
    });

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _setUserLocationMarker(context) async {
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
            zoom: 14.0,
          );
        });
        CameraPosition cameraPosition = CameraPosition(
            target: LatLng(locationLatitude, locationLongitude), zoom: 110);

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
          zoom: 14.0,
        );
        isLoading = false;
        _locationInitialized = true;
      });

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: 110);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      setState(() {});
    });
  }

  onCameraMove(CameraPosition? position) {
    setState(() {
      isLoading = true;
    });
    if (position != null) {
      _latitude = position.target.latitude;
      _longitude = position.target.longitude;

      // Cancel any ongoing debounce calls
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      // Set up a new debounce call
      _debounce = Timer(Duration(seconds: 1), () {
        //getAddressFromLatLng(latitude, longitude);
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
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  double bottomPaddingOfMap = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;

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
      body: _locationInitialized == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                  initialCameraPosition: _currentPosition,
                  mapType: MapType.normal,
                  myLocationEnabled: true, // Disable default blue dot
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  onCameraMove: onCameraMove,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);

                    setState(() {
                      bottomPaddingOfMap = 120.0;
                    });
                  },
                ),
                if (_locationInitialized)
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 -
                        28.5, // Center horizontally
                    top: MediaQuery.of(context).size.height / 2 -
                        22.5, // Center vertically
                    child: Image.asset(
                      "assets/icons/round_pin.gif",
                      color: Colors.green[600],
                      width: 45,
                      height: 45,
                    ),
                  ),
                Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.height / 2 -
                        65, // Adjust for tooltip position
                    child: CustomTooltip(message: 'Your Pickup Point')),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (_latitude != 0.0 || _longitude != 0.0) {
                                await getAddressFromLatLng(
                                    _latitude, _longitude);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                print("LatLng Error");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Ink(
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/buttton_bg.png"),
                                      fit: BoxFit.cover),
                                  color: ThemeClass.facebookBlue,
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
                                            'Confirm Pickup Location',
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
                        ),
                ),
              ],
            ),
    );
  }
}
