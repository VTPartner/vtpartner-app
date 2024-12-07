import 'dart:async';
import 'dart:typed_data';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/apps/constants/key.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/apps/widgets/column_builder.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'dart:ui' as ui;

import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/routings/route_names.dart' as oldRoutes;

import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';

class PickupLocation extends StatefulWidget {
  const PickupLocation({super.key});

  @override
  State<PickupLocation> createState() => _PickupLocationState();
}

class _PickupLocationState extends State<PickupLocation>
    with TickerProviderStateMixin {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  GoogleMapController? mapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 110,
  );

  List<Marker> allMarkers = [];
  Map<PolylineId, Polyline> polylines = {};

  bool _isChecked = false;
  bool _showBottomSheet = true;
  TextEditingController senderNameController = TextEditingController();
  TextEditingController senderNumberController = TextEditingController();

  final Completer<GoogleMapController> _controller = Completer();

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
        _locationInitialized = true;
      });

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: 110);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      setState(() {});
    });
  }

  @override
  void dispose() {
    mapController!.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          googleMap(),
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
          customInfoWindow(size),
          header(context),
          routeAddressBottomsheet(),
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

  onCameraMove(CameraPosition? position) {
    if (position != null) {
      //_customInfoWindowController.onCameraMove!();
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
    var sender_name = nameTextEditingController.text.toString().trim();
    var sender_number = numberTextEditingController.text.toString().trim();
    var numberCheck = sender_number;
    if (_latitude == 0.0 || _longitude == 0.0) {
      glb.showToast(
          "Please try after sometime we are not able to fetch your location");
      return;
    }

    if (sender_name.isEmpty) {
      glb.showToast("Please provide sender name.");
      return;
    }
    if (sender_number.isEmpty) {
      glb.showToast("Please provide sender number.");
      return;
    }
    if (numberCheck.startsWith("+91")) {
      // Ensure the number after "+91" has exactly 10 digits
      if (numberCheck.length != 13 ||
          !RegExp(r'^\+91\d{10}$').hasMatch(numberCheck)) {
        glb.showToast(
            "Please provide a valid 10-digit sender phone number with or without +91.");
        return;
      }
    } else {
      // Validate for exactly 10 digits without "+91"
      if (numberCheck.length != 10 ||
          !RegExp(r'^\d{10}$').hasMatch(numberCheck)) {
        glb.showToast("Please provide a valid 10-digit sender phone number.");
        return;
      }
    }

    if (_isServiceAvailable == false) {
      return;
    }

    AssistantMethods.saveSenderContactDetails(
        sender_name, numberCheck, context);

    if (_latitude != 0.0 || _longitude != 0.0) {
      await getAddressFromLatLng(_latitude, _longitude);
      Navigator.pushNamed(
          context, oldRoutes.PickUpAndDropBookingLocationsRoute);
      // Navigator.pop(context);
      // Navigator.pop(context);
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

  googleMap() {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow!();
      },
      onCameraMove: onCameraMove,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: _currentPosition,
      onMapCreated: mapCreated,
    );
  }

  routeAddressBottomsheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: BottomSheet(
            backgroundColor: Colors.transparent,
            enableDrag: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
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
                      color: blackColor.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(10, 0),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    heightSpace,
                    heightSpace,
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    height5Space,
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          horizontal: fixPadding * 2),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked,
                                color: Colors.green[900],
                                size: 20,
                              ),
                              widthSpace,
                              Expanded(
                                child: Text(
                                  Provider.of<AppInfo>(context)
                                              .userPickupLocation !=
                                          null
                                      ? Provider.of<AppInfo>(context)
                                          .userPickupLocation!
                                          .locationName!
                                      : "Please wait ...",
                                  style: semibold14Grey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    _showBottomSheet
                        ? Consumer<AppInfo>(builder: (context, appInfo, child) {
                            // Update the TextEditingController's text if senderContactDetail changes
                            final senderContact = appInfo.senderContactDetail;
                            // senderContact.contactNumber !=
                            //     numberTextEditingController.text
                            if (senderContact != null) {
                              // Update the controllers only if the user hasn't edited them

                              if (!isNumberEdited &&
                                  numberTextEditingController.text !=
                                      senderContact.contactNumber) {
                                numberTextEditingController.text =
                                    senderContact.contactNumber!;
                              }
                              if (!isNameEdited &&
                                  nameTextEditingController.text !=
                                      senderContact.contactName) {
                                nameTextEditingController.text =
                                    senderContact.contactName!;
                              }
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: TextField(
                                      onChanged: (value) {
                                        isNameEdited =
                                            true; // Mark as edited when the user modifies it
                                      },
                                      textInputAction: TextInputAction.done,
                                      style: nunitoSansStyle.copyWith(
                                        fontSize:
                                            12.0, // Adjust the font size as needed
                                        color: Colors.grey[
                                            900], // You can also change the text color if necessary
                                      ),
                                      controller: nameTextEditingController,
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width:
                                                0.1, // Adjust the border width here
                                          ),
                                        ),
                                        labelText: 'Sender Name',
                                        labelStyle: nunitoSansStyle.copyWith(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        hintText: "Enter Sender Name",
                                        hintStyle: nunitoSansStyle.copyWith(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                      ),
                                    ),
                                  ),
                                  // GoogleTextFormField(
                                  //     readOnly: false,
                                  //     textEditingController: nameTextEditingController,
                                  //     hintText: "Enter Sender Name",
                                  //     textInputType: TextInputType.text,
                                  //     labelText: 'Sender Name'),
                                  SizedBox(height: kHeight),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: TextField(
                                      readOnly: false,
                                      textInputAction: TextInputAction.done,
                                      style: nunitoSansStyle.copyWith(
                                        fontSize:
                                            12.0, // Adjust the font size as needed
                                        color: Colors.grey[
                                            900], // You can also change the text color if necessary
                                      ),
                                      onChanged: (value) {
                                        isNumberEdited =
                                            true; // Mark as edited when the user modifies it
                                      },
                                      controller: numberTextEditingController,
                                      keyboardType: TextInputType.phone,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  oldRoutes.SenderContactRoute);
                                            },
                                            icon: Icon(
                                              Icons.contact_phone_rounded,
                                              color: ThemeClass.facebookBlue,
                                              size: 16,
                                            )),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width:
                                                0.1, // Adjust the border width here
                                          ),
                                        ),
                                        labelText: 'Sender Mobile Number',
                                        labelStyle: nunitoSansStyle.copyWith(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        hintText: "Enter Sender Mobile Number",
                                        hintStyle: nunitoSansStyle.copyWith(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: kHeight),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            _isChecked = !_isChecked;
                                          });

                                          if (_isChecked) {
                                            setSenderDetailsToMyDetails(); // Call function to set sender details
                                          } else {
                                            final pref = await SharedPreferences
                                                .getInstance();
                                            pref.setString("sender_name", "");
                                            pref.setString("sender_number", "");
                                            nameTextEditingController.text = "";
                                            numberTextEditingController.text =
                                                "";
                                            Provider.of<AppInfo>(context,
                                                    listen: false)
                                                .updateSenderContactDetails(
                                                    null); // Clear sender details
                                          }
                                        },
                                        child: Container(
                                          width: 24, // Width of the checkbox
                                          height: 24, // Height of the checkbox
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _isChecked
                                                  ? ThemeClass.facebookBlue
                                                  : Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: customerNumber ==
                                                  numberTextEditingController
                                                      .text
                                              ? Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 20,
                                                    color:
                                                        ThemeClass.facebookBlue,
                                                  ),
                                                )
                                              : _isChecked
                                                  ? Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: ThemeClass
                                                            .facebookBlue,
                                                      ),
                                                    )
                                                  : null, // Only show the check icon if `_isChecked` is true
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      DescriptionText(
                                        descriptionText:
                                            'Use my mobile number. ${customerNumber}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: kHeight),
                                ],
                              ),
                            );
                          })
                        : SizedBox(),
                    _showBottomSheet
                        ? GestureDetector(
                            onTap: () {
                              savePickupLocationDetails();
                              //Navigator.pushNamed(context, '/selectCab');
                            },
                            child: Container(
                              width: double.maxFinite,
                              padding: const EdgeInsets.all(fixPadding * 1.3),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                boxShadow: buttonShadow,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Confirm Pickup Location",
                                style: bold18White,
                              ),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: fixPadding, right: fixPadding, top: fixPadding * 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              Text(
                "Pickup location",
                style: extrabold20Black,
              )
            ],
          ),
          Icon(
            Icons.search,
            size: 30,
          )
        ],
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

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    _controller.complete(controller);
    _customInfoWindowController.googleMapController = controller;
    // await marker();
    setState(() {});
  }
}
