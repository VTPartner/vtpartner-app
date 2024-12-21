import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/models/contact_model.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/global/global.dart' as glb;

class HandyManWorkMapLocationScreen extends StatefulWidget {
  const HandyManWorkMapLocationScreen({super.key});

  @override
  State<HandyManWorkMapLocationScreen> createState() =>
      _HandyManWorkMapLocationScreenState();
}

class _HandyManWorkMapLocationScreenState
    extends State<HandyManWorkMapLocationScreen> {
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
  double bottomPaddingOfMap = 0.0;
  bool _isServiceAvailable = false;
  bool isLoading = false; // To track the loading state
  Timer? _debounce;

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    setState(() {
      isLoading = true; // Start loading when camera moves
    });
    try {
      String humanReadableAddress =
          await AssistantMethods.mapLocationUsingFromLatLng(lat, lng, context);
      // print("New Work Location::$humanReadableAddress");
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
  String senderName = "", senderNumber = "", customerNumber = "";
  TextEditingController numberTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  bool isNumberEdited = false;
  bool isNameEdited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access the inherited widget here
    appInfo = Provider.of<AppInfo?>(context, listen: false);
  }

  setSenderDetailsToMyDetails() async {
    final pref = await SharedPreferences.getInstance();
    var customer_name = pref.getString("customer_name");
    var customer_mobile_no = pref.getString("mobile_no");

    if (customer_name != null && customer_mobile_no != null) {
      customerNumber = customer_mobile_no;
      AssistantMethods.saveSenderContactDetails(
          customer_name, customer_mobile_no, context);
    } else {
      MyApp.restartApp(context);
    }
    setState(() {});
  }

  getSenderDetails() async {
    final pref = await SharedPreferences.getInstance();
    var sender_name = pref.getString("sender_name");
    var sender_number = pref.getString("sender_number");
    var customer_name = pref.getString("customer_name");
    var customer_mobile_no = pref.getString("mobile_no");
    if (customer_mobile_no != null && customer_mobile_no.isNotEmpty) {
      customerNumber = customer_mobile_no;
    }
    print("sender_number::$sender_number");
    print("customer_mobile_no::$customer_mobile_no");
    if (sender_number == customer_mobile_no) {
      setState(() {
        _isChecked = true;
      });
    }
    // if (sender_name == null || sender_name.isEmpty) {
    //   nameTextEditingController.text =
    //       senderName = customer_name.toString().split(" ")[0];
    // } else {
    //   nameTextEditingController.text = senderName = sender_name;
    // }

    // if (sender_number == null || sender_number.isEmpty) {
    //   numberTextEditingController.text = senderNumber = customer_mobile_no!;
    // } else {
    //   numberTextEditingController.text = senderNumber = sender_number;
    // }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _currentPosition = _kGooglePlex;
    getSenderDetails();
    print("init Work location map");
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
    if (position != null) {
      _latitude = position.target.latitude;
      _longitude = position.target.longitude;

      // Cancel any ongoing debounce calls
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      // Set up a new debounce call
      _debounce = Timer(Duration(seconds: 1), () {
        getAddressFromLatLng(_latitude, _longitude);
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

  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _locationInitialized == false
            ? Center(
                child: CircularProgressIndicator(),
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
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      onCameraMove: onCameraMove,
                      onMapCreated: (GoogleMapController controller) {
                        setState(() {
                          bottomPaddingOfMap = 325.0;
                        });
                        _controller.complete(controller);
                      },
                    ),
                    if (_locationInitialized)
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 -
                            20, // Center horizontally
                        top: MediaQuery.of(context).size.height / 2 -
                            22.5, // Center vertically
                        child: SvgPicture.asset(
                          "assets/svg/blue_pinbar.svg",
                          // color: Colors.green[600],
                          width: 55,
                          height: 55,
                        ),
                      ),
                    _showBottomSheet
                        ? Positioned(
                            left: 0,
                            right: 0,
                            top: MediaQuery.of(context).size.height / 2 -
                                65, // Adjust for tooltip position
                            child: CustomTooltip(
                                message: 'This is your Work Location'))
                        : SizedBox(),
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
                  ],
                ),
              ),
        bottomSheet: _showBottomSheet
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)),
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        style: nunitoSansStyle.copyWith(
                          fontSize: 12.0, // Adjust the font size as needed
                          color: Colors.grey[
                              900], // You can also change the text color if necessary
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                            text: Provider.of<AppInfo>(context)
                                        .userPickupLocation !=
                                    null
                                ? Provider.of<AppInfo>(context)
                                    .userPickupLocation!
                                    .locationName!
                                : "Please wait ..."),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0.1, // Adjust the border width here
                            ),
                          ),
                          labelText: 'Work Location',
                          labelStyle: nunitoSansStyle.copyWith(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          hintText: 'Work Location',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    SizedBox(height: kHeight),
                    isLoading
                        ? Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(), // Loading animation
                            ),
                          )
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                savePickupLocationDetails();
                              },
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
                                            'Confirm Work Location',
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
              )
            : null);
  }

  Future<void> checkServiceAvailable() async {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userPickupLocation?.locationLatitude;
    var longitude = appInfo.userPickupLocation?.locationLongitude;
    var full_address = appInfo.userPickupLocation?.locationName;
    var pincode = appInfo.userPickupLocation?.pinCode;
    if (full_address == null) {
      MyApp.restartApp(context);
    }
    final data = {'pincode': pincode};

    final pref = await SharedPreferences.getInstance();

    setState(() {
      _isServiceAvailable = false;
      isLoading = true;
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
            "pickup_city_id", response["results"][0]["city_id"].toString());
        setState(() {
          _isServiceAvailable = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isServiceAvailable = false;
        isLoading = false;
      });
      pref.setString("pickup_city_id", "");
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        //glb.showToast("No Services Found.");

        _showServiceUnavailableBottomSheet(context);
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    }
  }

  savePickupLocationDetails() async {
    await checkServiceAvailable();

    if (_latitude == 0.0 || _longitude == 0.0) {
      glb.showToast(
          "Please try after sometime we are not able to fetch your location");
      return;
    }

    if (_isServiceAvailable == false) {
      return;
    }

    if (_latitude != 0.0 || _longitude != 0.0) {
      await getAddressFromLatLng(_latitude, _longitude);
      //Navigator.pushNamed(context, CabDestinationLocationSearchRoute);
      glb.showSnackBar(context,
          "Unfortunately, no service providers are available near your work location at this time.");
    } else {
      print("LatLng Error");
    }
  }

  void _showServiceUnavailableBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 300, // Set the height according to your design
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Image
              CircleAvatar(
                radius: 50, // Adjust radius as needed
                backgroundImage: const AssetImage(
                    'assets/images/no_service.png'), // Add your image path here
                backgroundColor: Colors.grey[
                    200], // Optional: background color if the image fails to load
              ),
              const SizedBox(height: 20), // Spacing between image and text
              // Message Text
              Text(
                Provider.of<AppInfo>(context).userPickupLocation != null
                    ? 'Unfortunately, we do not currently offer services in \n${Provider.of<AppInfo>(context).userPickupLocation!.locationName!} for this postal code.\n Please try a different location.'
                    : "Unable to retrieve your location. Please try again shortly.",
                textAlign: TextAlign.center,
                style: nunitoSansStyle.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomTooltip extends StatelessWidget {
  final String message;

  CustomTooltip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Tooltip Container
        Container(
          padding: EdgeInsets.all(26),
          decoration: BoxDecoration(
              // color: Colors.black,
              borderRadius: BorderRadius.circular(8.0)),
          child: Text(
            message,
            style: TextStyle(color: Colors.black, fontSize: 10.0),
          ),
        ),
        // Pointer Shape
        Visibility(
          visible: false,
          child: Positioned(
            top: 32, // Adjust position for the pointer
            child: CustomPaint(
              size: Size(20, 10), // Size of the triangle
              painter: TrianglePainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white;
    var path = Path();

    path.moveTo(size.width / 2, 0); // Top point of the triangle
    path.lineTo(0, size.height); // Bottom left point
    path.lineTo(size.width, size.height); // Bottom right point
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
