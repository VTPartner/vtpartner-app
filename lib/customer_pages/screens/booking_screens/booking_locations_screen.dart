import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/pickup_location_screen.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
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
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      onChange();
    });
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
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
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
                                descriptionText: "Shaheed . 8296565587"),
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
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, AddStopsRoute);
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
                                  DescriptionText(descriptionText: 'ADD STOPS')
                                ],
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  Navigator.pushNamed(context, DropLocateOnMapRoute);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.pin_drop,
                      size: 14,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Locate on the Map",
                      style: nunitoSansStyle.copyWith(fontSize: 14.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


}
