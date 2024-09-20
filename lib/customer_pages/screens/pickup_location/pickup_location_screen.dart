import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/global/map_key.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/models/predicted_places.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/main_heading_text.dart';
import 'package:vt_partner/widgets/small_text.dart';

class PickupLocationScreen extends StatefulWidget {
  const PickupLocationScreen({super.key});

  @override
  State<PickupLocationScreen> createState() => _PickupLocationScreenState();
}

class _PickupLocationScreenState extends State<PickupLocationScreen> {
  TextEditingController _controller = TextEditingController();
  var uuid = Uuid();
  String sessionToken = "1234556";
  List<PredictedPlaces> _placesPredictedList = [];
  var hideSuggestion = false;

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15.0),
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
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Where Can We Pick Up Your Package?',
                      border: InputBorder.none,
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
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
                                });
                              },
                            )
                          : null,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: false,
            child: Container(
              padding: const EdgeInsets.all(12.0),
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
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bookmark,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  HeadingText(title: "Saved")
                ],
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
                        SmallText(text: "Recent Search History"),
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
                        //getPlaceDirectionDetails(index, context);
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
                          directions.locationName = responseApi["result"]["formatted_address"];
                          print(
                              "Selected Pickup Location Name::${directions.locationName!.toString()}");
                          directions.locationLatitude = responseApi["result"]
                              ["geometry"]["location"]["lat"];
                          directions.locationLongitude = responseApi["result"]
                              ["geometry"]["location"]["lng"];

                          Provider.of<AppInfo>(context, listen: false)
                              .updatePickupLocationAddress(directions);
                          
                        } else {
                          if (kDebugMode) {
                            print("PLace Id details not found");
                          }

                          return;
                        }
                        // setState(() {
                        //   _controller.text =
                        //       _placesPredictedList[index].description!;
                        //   _placesPredictedList = [];
                        //   hideSuggestion = false;
                        //   FocusScope.of(context).unfocus();
                        // });
                        Navigator.pop(context);
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
                onTap: () {
                  Navigator.pushNamed(context, LocateOnMapPickupLocationRoute);
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

  placesAutoCompleteTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _controller,
        googleAPIKey: mapKey,
        inputDecoration: InputDecoration(
          hintText: "Search your pickup location",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: ["in", "fr"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lat.toString());
        },

        itemClick: (Prediction prediction) {
          _controller.text = prediction.description ?? "";
          _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        containerHorizontalPadding: 10,

        // OPTIONAL// If you want to customize list view item builder
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },

        isCrossBtnShown: true,

        // default 600 ms ,
      ),
    );
  }
}
