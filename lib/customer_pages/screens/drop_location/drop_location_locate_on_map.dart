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
import 'package:vt_partner/customer_pages/screens/pickup_location/locate_on_map_screen.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'package:vt_partner/global/global.dart' as glb;

class DropLocationLocateOnMap extends StatefulWidget {
  const DropLocationLocateOnMap({super.key});

  @override
  State<DropLocationLocateOnMap> createState() =>
      _DropLocationLocateOnMapState();
}

class _DropLocationLocateOnMapState extends State<DropLocationLocateOnMap> {
  bool _isChecked = false;

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.892953, 74.518013),
    zoom: 110,
  );

  var _address = "";
  double bottomPaddingOfMap = 0.0;
  bool isLoading = false; // To track the loading state
  Timer? _debounce;
  String receiverName = "", receiverNumber = "", customerNumber = "";
  TextEditingController numberTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  bool _isServiceAvailable = false;

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    setState(() {
      isLoading = true; // Start loading when camera moves
    });
    try {
      // List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      // if (placemarks.isNotEmpty) {
      //   Placemark place = placemarks[0];
      //   print("placess::" + place.toString());
      //   // print("Lat ::$lat Lng::$lng");
      //   // print("---End---");
      //   setState(() {
      //     _address =
      //         "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country} - ${place.postalCode}";
      //     isLoading = false; // Stop loading when address is found
      //   });
      // } else {
      //   setState(() {
      //     _address = "";
      //     isLoading = false; // Stop loading even if no address is found
      //   });
      // }
        String humanReadableAddress =
          await AssistantMethods.mapDropLocationUsingFromLatLng(
              lat, lng, context);
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
bool isNumberEdited = false;
  bool isNameEdited = false;

  setReceiverDetailsToMyDetails() async {
    final pref = await SharedPreferences.getInstance();
    var customer_name = pref.getString("customer_name");
    var customer_mobile_no = pref.getString("mobile_no");

    if (customer_name != null && customer_mobile_no != null) {
      customerNumber = customer_mobile_no;
      AssistantMethods.saveReceiverContactDetails(
          customer_name, customer_mobile_no, context);
    } else {
      MyApp.restartApp(context);
    }
    setState(() {});
  }

  getReceiverDetails() async {
    final pref = await SharedPreferences.getInstance();
    var receiver_name = pref.getString("receiver_name");
    var receiver_number = pref.getString("receiver_number");
    var customer_name = pref.getString("customer_name");
    var customer_mobile_no = pref.getString("mobile_no");
    if (customer_mobile_no != null && customer_mobile_no.isNotEmpty) {
      customerNumber = customer_mobile_no;
    }
    print("receiver_number::$receiver_number");
    print("customer_mobile_no::$customer_mobile_no");
    if (receiver_number == customer_mobile_no) {
      setState(() {
        _isChecked = true;
      });
    }
    // if (receiver_name == null || receiver_name.isEmpty) {
    //   nameTextEditingController.text =
    //       receiverName = customer_name.toString().split(" ")[0];
    // } else {
    //   nameTextEditingController.text = receiverName = receiver_name;
    // }

    // if (receiver_number == null || receiver_number.isEmpty) {
    //   numberTextEditingController.text = receiverNumber = customer_mobile_no!;
    // } else {
    //   numberTextEditingController.text = receiverNumber = receiver_number;
    // }
    setState(() {});
  }

  Future<void> checkServiceAvailable() async {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userDropOfLocation?.locationLatitude;
    var longitude = appInfo.userDropOfLocation?.locationLongitude;
    var full_address = appInfo.userDropOfLocation?.locationName;
    var pincode = appInfo.userDropOfLocation?.pinCode;
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
        // await pref.setString(
        //     "current_city_id", response["results"][0]["city_id"].toString());
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



  @override
  void initState() {
    super.initState();
    // Provider.of<AppInfo>(context,listen: false).receiverContactDetail = null;
    _currentPosition = _kGooglePlex;
    getReceiverDetails();
    print("Init Drop Location");
    _setUserLocationMarker();
    // checkServiceAvailable();
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

  AppInfo? appInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access the inherited widget here
    appInfo = Provider.of<AppInfo?>(context, listen: false);
  }


  Future<void> _setUserLocationMarker() async {
    
    getUserCurrentLocation().then((value) async {
      if (appInfo?.userDropOfLocation != null) {
        var locationLatitude = appInfo?.userDropOfLocation!.locationLatitude;
        var locationLongitude = appInfo?.userDropOfLocation!.locationLongitude;
        
        final userLocation = LatLng(locationLatitude!, locationLongitude!);
        setState(() {
          _userLocation = userLocation;
          _currentPosition = CameraPosition(
            target: _userLocation,
            zoom: 10.0,
          );
          _locationInitialized = true;
        });
        CameraPosition cameraPosition = CameraPosition(
            target: LatLng(locationLatitude, locationLongitude), zoom: 110);

        final GoogleMapController controller = await _controller.future;

        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setState(() {});
        return;
      }

      print("Drop Location::" +
          value.latitude.toString() +
          " " +
          value.longitude.toString());
      final userLocation = LatLng(value.latitude, value.longitude);
      setState(() {
        _userLocation = userLocation;
        _currentPosition = CameraPosition(
          target: _userLocation,
          zoom: 10.0,
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

  bool _showBottomSheet = true;

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
      _debounce = Timer(const Duration(seconds: 1), () {
        getAddressFromLatLng(_latitude, _longitude);
        setState(() {
          _showBottomSheet =
              true; // Show the bottom sheet when position is updated
          isLoading = false;
        });
        print("drop location setting here");
        // checkServiceAvailable();
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
            ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              top: false,
              bottom: true,
              child: Stack(
                children: [
                  if (_currentPosition != null)
                    GoogleMap(
                        padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                      initialCameraPosition: _currentPosition,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      onCameraMove: onCameraMove,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                          setState(() {
                            bottomPaddingOfMap = 325.0;
                          });
                      },
                    ),
                  if (_locationInitialized)
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 -
                            20, // Center horizontally
                      top: MediaQuery.of(context).size.height / 2 -
                          22.5, // Center vertically
                        child: SvgPicture.asset(
                          "assets/svg/red_pinbar.svg",
                          // color: Colors.green[600],
                          width: 55,
                          height: 55,
                        ),
                    ),
                    Positioned(
                        left: 0,
                        right: 0,
                        top: MediaQuery.of(context).size.height / 2 -
                            80, // Adjust for tooltip position
                        child: CustomTooltip(
                            message: 'This is your Drop Location')),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                              icon: const Icon(
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
            ? Consumer<AppInfo>(builder: (context, appInfo, child) {
                // Update the TextEditingController's text if receiverContactDetail changes
                final receiverContact = appInfo.receiverContactDetail;
                // if (receiverContact != null &&
                //     receiverContact.contactNumber !=
                //         numberTextEditingController.text) {
                //   numberTextEditingController.text =
                //       receiverContact.contactNumber!;
                //   nameTextEditingController.text = receiverContact.contactName!;
                // }
                if (receiverContact != null) {
                  // Update the controllers only if the user hasn't edited them
                  if (!isNumberEdited &&
                      numberTextEditingController.text !=
                          receiverContact.contactNumber) {
                    numberTextEditingController.text =
                        receiverContact.contactNumber!;
                  }
                  if (!isNameEdited &&
                      nameTextEditingController.text !=
                          receiverContact.contactName) {
                    nameTextEditingController.text =
                        receiverContact.contactName!;
                  }
                }
                return Container(
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
                                          .userDropOfLocation !=
                                      null
                                  ? Provider.of<AppInfo>(context)
                                      .userDropOfLocation!
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
                            labelText: 'Drop Location',
                            labelStyle: nunitoSansStyle.copyWith(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            hintText: 'Drop Location',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),
                      SizedBox(height: kHeight),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)),
                        child: TextField(
                          onChanged: (value) {
                            isNameEdited =
                                true; // Mark as edited when the user modifies it
                          },
                          textInputAction: TextInputAction.done,
                          style: nunitoSansStyle.copyWith(
                            fontSize: 12.0, // Adjust the font size as needed
                            color: Colors.grey[
                                900], // You can also change the text color if necessary
                          ),
                          controller: nameTextEditingController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 0.1, // Adjust the border width here
                              ),
                            ),
                            labelText: 'Receiver Name',
                            labelStyle: nunitoSansStyle.copyWith(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            hintText: "Enter Receiver Name",
                            hintStyle: nunitoSansStyle.copyWith(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),

                      // GoogleTextFormField(
                      //     readOnly: false,
                      //     textEditingController: nameTextEditingController,
                      //     hintText: "Enter Delivery Recipient Name",
                      //     textInputType: TextInputType.text,
                      //     labelText: 'Delivery Recipient Name'),
                      SizedBox(height: kHeight),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)),
                        child: TextField(
                          readOnly: false,
                          textInputAction: TextInputAction.done,
                          style: nunitoSansStyle.copyWith(
                            fontSize: 12.0, // Adjust the font size as needed
                            color: Colors.grey[
                                900], // You can also change the text color if necessary
                          ),
                          controller: numberTextEditingController,
                          keyboardType: TextInputType.phone,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, ReceiverContactRoute);
                                },
                                icon: const Icon(
                                  Icons.contact_phone_rounded,
                                  color: ThemeClass.facebookBlue,
                                  size: 16,
                                )),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 0.1, // Adjust the border width here
                              ),
                            ),
                            labelText: 'Delivery Recipient Mobile Number',
                            labelStyle: nunitoSansStyle.copyWith(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            hintText: "Enter Delivery Recipient Mobile Number",
                            hintStyle: nunitoSansStyle.copyWith(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                                setReceiverDetailsToMyDetails();
                              } else {
                                final pref =
                                    await SharedPreferences.getInstance();
                                pref.setString("receiver_name", "");
                                pref.setString("receiver_number", "");
                                nameTextEditingController.text = "";
                                numberTextEditingController.text = "";
                                Provider.of<AppInfo>(context, listen: false)
                                    .updateReceiverContactDetails(null);
                              }
            
                            },
                            child: Container(
                              width: 24, // Adjusted for better visual alignment
                              height:
                                  24, // Adjusted for better visual alignment
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _isChecked
                                      ? ThemeClass.facebookBlue
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: customerNumber ==
                                      numberTextEditingController.text
                                  ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        size:
                                            20, // Adjusted size to fit within the container
                                        color: ThemeClass.facebookBlue,
                                      ),
                                    )
                                  : _isChecked
                                      ? const Center(
                                          child: Icon(
                                            Icons.check,
                                            size:
                                                20, // Adjusted size to fit within the container
                                            color: ThemeClass.facebookBlue,
                                          ),
                                        )
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          DescriptionText(
                              descriptionText:
                                  'Use my mobile number. ${customerNumber}')
                        ],
                      ),
                      SizedBox(height: kHeight),
                      isLoading
                          ? const Center(
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
                                  saveDropLocationDetails();
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
                                              'Verify',
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
                );
              })
            : null);
  }

  saveDropLocationDetails() async {
    await checkServiceAvailable();
    var receiver_name = nameTextEditingController.text.toString().trim();
    var receiver_number = numberTextEditingController.text.toString().trim();
    var numberCheck = receiver_number;
    if (_latitude == 0.0 || _longitude == 0.0) {
      glb.showToast(
          "Please try after sometime we are not able to fetch your location");
      return;
    }

    if (receiver_name.isEmpty) {
      glb.showToast("Please provide Receiver name.");
      return;
    }
    if (receiver_number.isEmpty) {
      glb.showToast("Please provide Receiver number.");
      return;
    }
    // Check if the number starts with "+91" and validate accordingly
    if (numberCheck.startsWith("+91")) {
      // Ensure the number after "+91" has exactly 10 digits
      if (numberCheck.length != 13 ||
          !RegExp(r'^\+91\d{10}$').hasMatch(numberCheck)) {
        glb.showToast(
            "Please provide a valid 10-digit receiver phone number with or without +91.");
        return;
      }
    } else {
      // Validate for exactly 10 digits without "+91"
      if (numberCheck.length != 10 ||
          !RegExp(r'^\d{10}$').hasMatch(numberCheck)) {
        glb.showToast("Please provide a valid 10-digit receiver phone number.");
        return;
      }
    }

    if (_isServiceAvailable == false) {
      return;
    }

// Proceed to save the contact details
    AssistantMethods.saveReceiverContactDetails(
        receiver_name, numberCheck, context);

    if (_latitude != 0.0 || _longitude != 0.0) {
      await getAddressFromLatLng(_latitude, _longitude);
      Navigator.pushReplacementNamed(context, PickToDropPolyLineMapRoute);
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
                Provider.of<AppInfo>(context).userDropOfLocation != null
                    ? 'Unfortunately, we do not currently offer services in \n${Provider.of<AppInfo>(context).userDropOfLocation!.locationName!} for this postal code.\n Please try a different location.'
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
