import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/add_stops_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/pickup_location_screen.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/models/predicted_places.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/global_filled_button.dart';
import 'package:vt_partner/widgets/global_outlines_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:http/http.dart' as http;
import 'package:vt_partner/global/global.dart' as glb;
import 'package:uuid/uuid.dart';
import 'package:vt_partner/widgets/small_text.dart';

class BookingLocationsScreen extends StatefulWidget {
  const BookingLocationsScreen({super.key});

  @override
  State<BookingLocationsScreen> createState() => _BookingLocationsScreenState();
}

class _BookingLocationsScreenState extends State<BookingLocationsScreen> {
  TextEditingController _controller = TextEditingController();
  var uuid = Uuid();
  String sessionToken = "1234556";
  List<PredictedPlaces> _placesPredictedList = [];
  var hideSuggestion = false;
  var isLoading = false;
  var senderName = "", senderNumber = "";
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      onChange();
    });

    getSenderDetails();
  }

  getSenderDetails() async {
    final pref = await SharedPreferences.getInstance();
    var sender_name = pref.getString("sender_name");
    var sender_number = pref.getString("sender_number");
    var customer_name = pref.getString("customer_name");
    var customer_mobile_no = pref.getString("mobile_no");
    if (sender_name == null ||
        sender_name.isEmpty ||
        sender_number == null ||
        sender_number.isEmpty) {
      senderName = customer_name.toString().split(" ")[0];
      AssistantMethods.saveSenderContactDetails(
          customer_name!, customer_mobile_no!, context);
    } else {
      senderName = sender_name;
    }

    if (sender_number == null || sender_number.isEmpty) {
      senderNumber = customer_mobile_no!;
      AssistantMethods.saveSenderContactDetails(
          customer_name!, customer_mobile_no!, context);
    } else {
      senderNumber = sender_number;
    }

    setState(() {});
  }

  bool serviceAvailable = false;

  Future<void> checkServiceAvailable() async {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userPickupLocation?.locationLatitude;
    var longitude = appInfo.userPickupLocation?.locationLongitude;
    var full_address = appInfo.userPickupLocation?.locationName;
    var pincode = appInfo.userPickupLocation?.pinCode;
    print("pickup location::$full_address");
    if (full_address == null) {
      MyApp.restartApp(context);
    }
    final data = {'pincode': pincode};

    final pref = await SharedPreferences.getInstance();

    setState(() {
      serviceAvailable = false;
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
          isLoading = false;
          serviceAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        serviceAvailable = false;
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
                    ? 'Unfortunately, we do not currently offer services in \n${Provider.of<AppInfo>(context).userPickupLocation!.locationName!} for this postal code.\n Please try a different pickup location.'
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


  void onChange() {
    if (sessionToken == null) {
      setState(() {
        sessionToken = uuid.v4();
      });
    }
    if (_controller.text.isNotEmpty) {
      getSuggestions(_controller.text);
      setState(() {
        hideSuggestion = true;
      });
    } else {
      setState(() {
        hideSuggestion = false;
        _placesPredictedList = [];
      });
    }
  }

  void getSuggestions(String input) async {
    String kPLACES_API_KEY = mapKey;
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$sessionToken';

    var responseAutoCompleteSearch =
        await RequestAssistant.receiveRequest(request);
    if (responseAutoCompleteSearch == "Error") {
      return;
    }

    if (responseAutoCompleteSearch["status"] == "OK") {
      var placePredictions = responseAutoCompleteSearch["predictions"];
      var placePredictionsList = (placePredictions as List)
          .map((jsonData) => PredictedPlaces.fromJson(jsonData))
          .toList();
      setState(() {
        _placesPredictedList = placePredictionsList;
      });
    }
  }

  Future<void> _getUserLocationAndAddress() async {
    print("obtain address");
    try {
      Position position = await getUserCurrentLocation();
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoOrdinates(
              position!, context, true);
      final appInfo = Provider.of<AppInfo>(context, listen: false);
      var locationId = appInfo.userCurrentLocation?.locationId;
      var latitude = appInfo.userCurrentLocation?.locationLatitude;
      var longitude = appInfo.userCurrentLocation?.locationLongitude;
      var full_address = appInfo.userCurrentLocation?.locationName;
      var pincode = appInfo.userCurrentLocation?.pinCode;

      Directions userCurrentLocation = Directions();
      userCurrentLocation.locationLatitude = latitude;
      userCurrentLocation.locationLongitude = longitude;
      userCurrentLocation.pinCode = pincode;
      userCurrentLocation.locationName = full_address;
      userCurrentLocation.locationId = locationId;
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOfLocationAddress(userCurrentLocation);

      print("MyCurrent Location::" + humanReadableAddress);
      Navigator.pushNamed(context, DropLocateOnMapRoute);
    } catch (e) {}
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
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      HeadingText(title: 'Select Booking Addresses'),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0)),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: width -
                                  80, // Takes the full width of the parent
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Pickup Location",
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.green[900],
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.fontSize),
                                    overflow: TextOverflow.visible,
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, PickUpAddressRoute);
                                      },
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Ink(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 1.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                          border: Border.all(
                                            color: ThemeClass
                                                .facebookBlue, // Border color
                                            width: 2.0, // Border width
                                          ),
                                          color: Colors
                                              .transparent, // Background color (transparent for outline)
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Change',
                                              style: robotoStyle.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: ThemeClass
                                                    .facebookBlue, // Text color matches the border
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            DescriptionText(
                                      descriptionText: Provider.of<AppInfo>(
                                                      context)
                                                  .senderContactDetail !=
                                              null
                                          ? "${Provider.of<AppInfo>(context).senderContactDetail!.contactName} . ${Provider.of<AppInfo>(context).senderContactDetail!.contactNumber}"
                                          : "${senderName} . ${senderNumber}"),
                            SizedBox(
                              width: width - 80,
                              child: BodyText1(
                                  text: Provider.of<AppInfo>(context)
                                              .userPickupLocation !=
                                          null
                                      ? Provider.of<AppInfo>(context)
                                          .userPickupLocation!
                                          .locationName!
                                      : Provider.of<AppInfo>(context)
                                                  .userCurrentLocation !=
                                              null
                                          ? Provider.of<AppInfo>(context)
                                              .userCurrentLocation!
                                              .locationName!
                                          : "Error Loading Your Location"),
                            ),
                            SizedBox(
                              height: kHeight,
                            ),
                            SizedBox(
                              width: width - 80,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15)),
                                child: TextField(
                                  textInputAction: TextInputAction.done,
                                  style: nunitoSansStyle.copyWith(
                                    fontSize:
                                        12.0, // Adjust the font size as needed
                                    color: Colors.grey[
                                        900], // You can also change the text color if necessary
                                  ),
                                  controller: Provider.of<AppInfo>(context)
                                              .userDropOfLocation !=
                                          null
                                      ? TextEditingController(
                                          text: Provider.of<AppInfo>(context)
                                              .userDropOfLocation!
                                              .locationName!)
                                      : _controller,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width:
                                            0.1, // Adjust the border width here
                                      ),
                                    ),
                                    labelText: 'Drop Location',
                                    labelStyle: nunitoSansStyle.copyWith(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    hintText: 'Where do you want it delivered?',
                                    hintStyle: nunitoSansStyle.copyWith(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _controller.clear(); // Clear the text
                                          _placesPredictedList =
                                              []; // Clear the search list
                                          hideSuggestion =
                                              false; // Hide the suggestions
                                          Provider.of<AppInfo>(context,
                                                  listen: false)
                                              .updateDropOfLocationAddress(
                                                  null);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                          Visibility(
                            visible: false,
                            child: InkWell(
                              onTap: () {
                                // Navigator.pushNamed(context, AddStopsRoute);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    DescriptionText(
                                        descriptionText: 'ADD STOPS')
                                  ],
                                ),
                              ),
                            ),
                          )
                  
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: !hideSuggestion,
            child: Expanded(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SmallText(text: "Recent Search History"),
                        Text(
                          "0 Found",
                          style: nunitoSansStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    Divider(
                      thickness: .2,
                      color: Colors.grey,
                    ),
                    // This is where the list of places would be shown as the user types
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: hideSuggestion,
            child: Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _placesPredictedList.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1), // Bottom divider
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.location_on,
                          color: Colors.grey,
                          size: 20), // Icon styled like Google Maps
                      onTap: () async {
                        // List<Location> locations = await locationFromAddress(
                        //     _placesPredictedList[index]['description']);
                        //TODO: ADD PROGRESS DIALOG UNTIL PLACE ID IS FOUND

                        String placeId = _placesPredictedList[index].place_id!;
                        String placeDirectionDetailsUrl =
                            "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

                        var responseApi = await RequestAssistant.receiveRequest(
                            placeDirectionDetailsUrl);

                        if (responseApi == "Error") {
                          print("Something Went Wrong");

                          return;
                        }
//https://developers.google.com/maps/documentation/places/web-service/details#json
                        if (responseApi["status"] == "OK") {
                          Directions directions = Directions();
                          directions.locationId = placeId;
                          directions.locationName =
                              // responseApi["result"]["name"];
                              directions.locationName =
                                  responseApi["result"]["formatted_address"];
                          print(
                                    "Selected Drop Location Name::${directions.locationName!.toString()}");
                          directions.locationLatitude = responseApi["result"]
                              ["geometry"]["location"]["lat"];
                          directions.locationLongitude = responseApi["result"]
                              ["geometry"]["location"]["lng"];

                          Provider.of<AppInfo>(context, listen: false)
                              .updateDropOfLocationAddress(directions);
                                Navigator.pushNamed(
                                    context, DropLocateOnMapRoute);
                        } else {
                          if (kDebugMode) {
                            print("PLace Id details not found");
                          }

                          return;
                        }
                        setState(() {
                          _controller.text =
                              _placesPredictedList[index].description!;
                          _placesPredictedList = [];
                          hideSuggestion = false;
                          FocusScope.of(context)
                              .unfocus(); // Disable focus on TextFormField
                        });
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _placesPredictedList[index].description!,
                            style: nunitoSansStyle.copyWith(
                              fontSize: 12,
                              color: Colors
                                  .black, // Darker text color for better visibility
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        await checkServiceAvailable();
                        if (serviceAvailable) _getUserLocationAndAddress();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: Colors.grey,
                            size: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Use my current location",
                            style: nunitoSansStyle.copyWith(fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      width: 2,
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        await checkServiceAvailable();
                        if (serviceAvailable)
                          Navigator.pushNamed(context, DropLocateOnMapRoute);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.map_sharp,
                            color: Colors.grey,
                            size: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Locate on the Map",
                            style: nunitoSansStyle.copyWith(fontSize: 12.0),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: kHeight,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await checkServiceAvailable();
                      if (serviceAvailable)
                        Navigator.pushNamed(context, DropLocateOnMapRoute);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage("assets/images/buttton_bg.png"),
                            fit: BoxFit.cover),
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
                                  'Continue',
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
          ),
        ),
      ),
    
    );
  }


}

