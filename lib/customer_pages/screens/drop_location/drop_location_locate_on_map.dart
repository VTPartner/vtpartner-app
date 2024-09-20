import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

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
  bool isLoading = false; // To track the loading state
  Timer? _debounce;

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

  @override
  void initState() {
    super.initState();
    // Provider.of<AppInfo>(context,listen: false).receiverContactDetail = null;
    _currentPosition = _kGooglePlex;
    _setUserLocationMarker();
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

  Future<void> _setUserLocationMarker() async {
    getUserCurrentLocation().then((value) async {
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

  bool _showBottomSheet = true;

  onCameraMove(CameraPosition? position) {
    if (position != null) {
      final latitude = position.target.latitude;
      final longitude = position.target.longitude;

      // Cancel any ongoing debounce calls
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      // Set up a new debounce call
      _debounce = Timer(Duration(seconds: 1), () {
        getAddressFromLatLng(latitude, longitude);
        setState(() {
          _showBottomSheet =
              true; // Show the bottom sheet when position is updated
        });
      });

      // Hide bottom sheet when user moves the marker
      if (_showBottomSheet) {
        setState(() {
          _showBottomSheet = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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
                  if (_currentPosition != null)
                    GoogleMap(
                      initialCameraPosition: _currentPosition,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      onCameraMove: onCameraMove,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  if (_locationInitialized)
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 -
                          22.5, // Center horizontally
                      top: MediaQuery.of(context).size.height / 2 -
                          22.5, // Center vertically
                      child: Image.asset(
                        "assets/icons/round_pin.gif",
                        color: Colors.red,
                        width: 45,
                        height: 45,
                      ),
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: TextField(
                textInputAction: TextInputAction.done,
                style: nunitoSansStyle.copyWith(
                  fontSize: 12.0, // Adjust the font size as needed
                  color: Colors.grey[
                      900], // You can also change the text color if necessary
                ),
                readOnly: true,
                controller: TextEditingController(text: Provider.of<AppInfo>(context)
                                        .userDropOfLocation !=
                                    null
                                ? Provider.of<AppInfo>(context)
                                    .userDropOfLocation!
                                    .locationName!
                                : "Please wait ..."),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
            GoogleTextFormField(
               readOnly: true,
                        textEditingController: TextEditingController(
                            text: Provider.of<AppInfo>(context)
                                        .receiverContactDetail !=
                                    null
                                ? Provider.of<AppInfo>(context)
                                    .receiverContactDetail!
                                    .contactName!
                                : ""),
                hintText: "Enter Delivery Recipient Name",
                textInputType: TextInputType.text,
                labelText: 'Delivery Recipient Name'),
            SizedBox(height: kHeight),
             Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)),
                      child: TextField(
                        readOnly: true,
                        textInputAction: TextInputAction.done,
                        style: nunitoSansStyle.copyWith(
                          fontSize: 12.0, // Adjust the font size as needed
                          color: Colors.grey[
                              900], // You can also change the text color if necessary
                        ),
                        controller: TextEditingController(
                            text: Provider.of<AppInfo>(context)
                                        .receiverContactDetail !=
                                    null
                                ? Provider.of<AppInfo>(context)
                                    .receiverContactDetail!
                                    .contactNumber!
                                : ""),
                        keyboardType: TextInputType.phone,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ReceiverContactRoute);
                              },
                              icon: Icon(
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
                  onTap: () {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                  child: Container(
                    width: 24, // Adjusted for better visual alignment
                    height: 24, // Adjusted for better visual alignment
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            _isChecked ? ThemeClass.facebookBlue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: _isChecked
                        ? Center(
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
                SizedBox(width: 8),
                DescriptionText(
                    descriptionText: 'Use my mobile number. 8296565587')
              ],
            ),
            SizedBox(height: kHeight),
            isLoading
                ? Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(), // Loading animation
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, SelectVehiclesRoute);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: ThemeClass.facebookBlue,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Verify and Continue',
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
      ): null
    );
  }
}
