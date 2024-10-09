import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/pickup_screens/location_on_map_pickup.dart';
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
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/small_text.dart';

class CabUserSearchDestinationLocationScreen extends StatefulWidget {
  const CabUserSearchDestinationLocationScreen({super.key});

  @override
  State<CabUserSearchDestinationLocationScreen> createState() =>
      _CabUserSearchDestinationLocationScreenState();
}

class _CabUserSearchDestinationLocationScreenState
    extends State<CabUserSearchDestinationLocationScreen> {
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
      setState(() {
        isLoading = true;
      });
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
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (responseAutoCompleteSearch["status"] == "OK") {
      var placePredictions = responseAutoCompleteSearch["predictions"];
      var placePredictionsList = (placePredictions as List)
          .map((jsonData) => PredictedPlaces.fromJson(jsonData))
          .toList();
      setState(() {
        _placesPredictedList = placePredictionsList;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
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
                HeadingText(title: 'Destination'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.7), // Shadow color
                    offset: Offset(0, 0),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, CabPickupLocationSearchRoute);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(
                              "assets/icons/green_dot.png",
                              width: 10,
                              height: 10,
                            ),
                            SizedBox(
                              width: width - 80,
                              child: Text(
                                Provider.of<AppInfo>(context)
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
                                        : "Error Loading Your Location",
                                style: nunitoSansStyle.copyWith(
                                    color: Colors.grey, fontSize: 12.0),
                                overflow: TextOverflow
                                    .ellipsis, // Adds ellipsis when text overflows
                                maxLines: 1, // Limits the text to a single line
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 0.3,
                      color: Colors.grey,
                      indent: 35,
                      endIndent: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.asset(
                            "assets/icons/red_dot.png",
                            width: 10,
                            height: 10,
                          ),
                          SizedBox(
                            width: width - 130,
                            child: TextField(
                              textInputAction: TextInputAction.done,
                              controller: Provider.of<AppInfo>(context)
                                          .userDropOfLocation !=
                                      null
                                  ? TextEditingController(
                                      text: Provider.of<AppInfo>(context)
                                          .userDropOfLocation!
                                          .locationName!)
                                  : _controller,
                              keyboardType: TextInputType.text,
                              style: nunitoSansStyle.copyWith(
                                color: Colors.grey, // Same as hintText color
                              ),
                              decoration: InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: 'Enter Destination',
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
                                            .updateDropOfLocationAddress(null);
                                      });
                                    },
                                  ),
                                  hintStyle: nunitoSansStyle.copyWith(
                                      fontSize: 12, color: Colors.grey)),
                            ),
                          ),
                          Text(
                            '|',
                            style: nunitoSansStyle.copyWith(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                          Icon(
                            Icons.add,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
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
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 5.0, // Set the height of the progress indicator
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red, // Start color
                          Colors.green, // End color
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: const LinearProgressIndicator(
                      value: 0.7, // Set the progress value
                      backgroundColor:
                          Colors.transparent, // Make background transparent
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.transparent), // Hide default color
                    ),
                  ),
                )
              : Visibility(
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

                              String placeId =
                                  _placesPredictedList[index].place_id!;
                              String placeDirectionDetailsUrl =
                                  "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

                              var responseApi =
                                  await RequestAssistant.receiveRequest(
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
                                        responseApi["result"]
                                            ["formatted_address"];
                                print(
                                    "Selected Drop Location Name::${directions.locationName!.toString()}");
                                directions.locationLatitude =
                                    responseApi["result"]["geometry"]
                                        ["location"]["lat"];
                                directions.locationLongitude =
                                    responseApi["result"]["geometry"]
                                        ["location"]["lng"];

                                Provider.of<AppInfo>(context, listen: false)
                                    .updateDropOfLocationAddress(directions);
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
                                Navigator.pushNamed(
                                    context, CabLocationsConfirmRoute);
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
                  Navigator.pushNamed(
                      context, CabLocateOnMapDestinationLocationRoute);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.pin_drop_rounded,
                      color: Colors.grey,
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
