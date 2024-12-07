import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/active_nearby_goods_drivers.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/shimmer_card.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:http/http.dart' as http;

class VehiclesAvailableScreen extends StatefulWidget {
  const VehiclesAvailableScreen({super.key});

  @override
  State<VehiclesAvailableScreen> createState() =>
      _VehiclesAvailableScreenState();
}

class _VehiclesAvailableScreenState extends State<VehiclesAvailableScreen> {
  int selectedIndex = 0;
  bool isLoading = false;
  bool showError = true;
  List<ActiveNearByGoodsDrivers> activeNearByGoodsDrivers = [];
  String? totalDurationText;
  double totalDistance = 1;
  String? totalDistanceText;

  Future<void> getOnlineGoodsDrivers() async {
    print("getting online drivers vehicle details");
    final pref = await SharedPreferences.getInstance();

    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userPickupLocation?.locationLatitude;
    var longitude = appInfo.userPickupLocation?.locationLongitude;
    var full_address = appInfo.userPickupLocation?.locationName;
    var pincode = appInfo.userPickupLocation?.pinCode;

    if (appInfo == null ||
        longitude == null ||
        full_address == null ||
        full_address.isEmpty) {
      MyApp.restartApp(context);
    }
    var price_type = 1;
    var pickup_city_id = pref.getString("pickup_city_id");
    if (pickup_city_id == null || pickup_city_id.isEmpty) {
      glb.showToast("Please verify your pickup location again");
      return;
    }

    final data = {
      'lat': latitude,
      'lng': longitude,
      'city_id': pickup_city_id,
      'price_type': price_type,
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
      var pickupLat = appInfo.userPickupLocation?.locationLatitude;
      var pickupLng = appInfo.userPickupLocation?.locationLongitude;
      var nearbyDrivers = response['nearby_drivers'];

      // Check if the response contains 'results' key and parse it
      if (nearbyDrivers != null && nearbyDrivers.isNotEmpty) {
        List<dynamic> servicesData = response['nearby_drivers'];
        List<ActiveNearByGoodsDrivers> drivers = servicesData
            .map(
                (serviceJson) => ActiveNearByGoodsDrivers.fromJson(serviceJson))
            .toList();
        // Fetch distance and arrival time for each driver
        await getDistanceAndTime(drivers, pickupLat!, pickupLng!);
      } else {
        print("show error here");
        setState(() {
          showError = true;
          activeNearByGoodsDrivers = [];
        });
        glb.showToast("No drivers found nearby. Please try again later.");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        showError = true;
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

  Future<void> getDistanceBetweenTwoPoints() async {
    print("Calculating Distance");
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var origin = appInfo.userPickupLocation?.locationId;
    var destination = appInfo.userDropOfLocation?.locationId;

    final data = {
      'origins': origin,
      'destinations': destination,
    };

    print("distance_data::$data");

    Provider.of<AppInfo>(context, listen: false).updateBookingDetails(null);

    setState(() {
      isLoading = true;
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/distance', data);
      if (kDebugMode) {
        print(response);
      }
      // Extract the duration text

      if (response['rows'] != null && response['rows'].isNotEmpty) {
        final elements = response['rows'][0]['elements'];
        if (elements != null && elements.isNotEmpty) {
          totalDurationText = elements[0]['duration']['text'];
          totalDistanceText = elements[0]['distance']['text'];
        }
      }

      if (totalDurationText != null) {
        // Extract only the numeric part from totalDistanceText using a regular expression
        final numericPart = RegExp(r'\d+(\.\d+)?').stringMatch(
            totalDistanceText!); // Finds the first decimal or integer number

        if (numericPart != null) {
          totalDistance = double.parse(
              numericPart); // Convert the extracted part to a double
        } else {
          // Handle case where no numeric part was found
          totalDistance = 0.0; // Or any default value you want
        }
        print(
            "Duration: $totalDurationText"); // This should print "Duration: 10 mins"
        print(
            "Distance: $totalDistanceText"); // This should print "Distance calculated by google api"
      } else {
        print("Duration not found.");
      }

      getOnlineGoodsDrivers();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      if (e.toString().contains("No Data Found")) {
        glb.showToast(
            "No Drivers Found in your location try to refresh and search again.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
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
      showError = false;
    });
    // Update state
    setState(() {
      activeNearByGoodsDrivers = drivers;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDistanceBetweenTwoPoints();
  }

  Future<void> _handleRefresh() async {
    getDistanceBetweenTwoPoints();
  }

  Future<void> saveBookingDetails() async {
    if (activeNearByGoodsDrivers.isEmpty) {
      glb.showToast("Please select the vehicle you would like to proceed");
      return;
    }
    var totalPrice =
        activeNearByGoodsDrivers[selectedIndex].perKmPrice! * totalDistance;
    AssistantMethods.saveBookingDetails(
        activeNearByGoodsDrivers[selectedIndex].driverId,
        activeNearByGoodsDrivers[selectedIndex].vehicleId,
        activeNearByGoodsDrivers[selectedIndex].vehicleImage!,
        activeNearByGoodsDrivers[selectedIndex].vehicleName!,
        activeNearByGoodsDrivers[selectedIndex].vehicleWeight!,
        totalDurationText!,
        totalDistance,
        totalPrice,
        activeNearByGoodsDrivers[selectedIndex].basePrice!,
        context);

    Navigator.pushNamed(context, BookingReviewDetailsRoute);
  }

  void showDriverModal(BuildContext context, ActiveNearByGoodsDrivers driver) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('${driver.vehicleSizeImage}'),
                      fit: BoxFit.contain,
                    ),
                    // border: Border.all(color: Colors.blue, width: 3),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                driver.vehicleName!,
                style: nunitoSansStyle.copyWith(
                  decoration: TextDecoration.none,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 5),
              Text(
                driver.driverName!,
                style: nunitoSansStyle.copyWith(
                  decoration: TextDecoration.none,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Price per km: ₹${driver.perKmPrice}',
                style: nunitoSansStyle.copyWith(
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.blue[900]),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
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
        body: Column(
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
                  HeadingText(title: 'Available Drivers'),
                ],
              ),
            ),
            SizedBox(
              height: kHeight,
            ),
            isLoading
                ? Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.2),
                      highlightColor: Colors.grey.withOpacity(0.1),
                      enabled: isLoading,
                      child: RefreshIndicator(
                        onRefresh: (_handleRefresh),
                        child: ListView.separated(
                            itemCount: 10,
                            separatorBuilder: (context, _) =>
                                SizedBox(height: height * 0.02),
                            itemBuilder: ((context, index) {
                              return const ShimmerCardLayout();
                            })),
                      ),
                    ),
                  )
                : activeNearByGoodsDrivers.isNotEmpty
                    ? Expanded(
                        child: RefreshIndicator(
                          onRefresh: (_handleRefresh),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: activeNearByGoodsDrivers
                                .length, // Change the item count as needed.
                            itemBuilder: (context, index) {
                              double totalPrice =
                                  activeNearByGoodsDrivers[index].perKmPrice! *
                                      totalDistance;
                              String formattedPrice =
                                  (double.parse(totalPrice.toStringAsFixed(2)))
                                      .toString();

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex =
                                          index; // Update the selected index on tap.
                                    });
                                    showDriverModal(context,
                                        activeNearByGoodsDrivers[index]);
                                  },
                                  child: Ink(
                                      decoration: BoxDecoration(
                                        color: selectedIndex == index
                                            ? ThemeClass.facebookBlue
                                                .withOpacity(0.1)
                                            : Colors
                                                .white, // Highlight the selected item.
                                      ),
                                      child: Stack(
                                        children: [
                                          selectedIndex == index
                                              ? Container(
                                                  width: 5,
                                                  height:
                                                      95, // Set to the same height as the column
                                                  decoration: BoxDecoration(
                                                      color: ThemeClass
                                                          .facebookBlue,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      12.0),
                                                              bottomRight: Radius
                                                                  .circular(
                                                                      12.0))),
                                                )
                                              : SizedBox(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2.0,
                                                right: 2.0,
                                                bottom: 2.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: kHeight,
                                                        ),
                                                        CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: ClipOval(
                                                            child:
                                                                Image.network(
                                                              activeNearByGoodsDrivers[
                                                                      index]
                                                                  .driverProfilePic!,
                                                              fit: BoxFit.cover,
                                                              width: 80,
                                                              height: 80,
                                                            ),
                                                          ),
                                                        ),
                                                      
                                                        SizedBox(
                                                          width: kHeight,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            DescriptionText(
                                                                descriptionText:
                                                                    activeNearByGoodsDrivers[
                                                                            index]
                                                                        .driverName!),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            DescriptionText(
                                                                descriptionText:
                                                                    activeNearByGoodsDrivers[
                                                                            index]
                                                                        .vehicleName!),
                                                            // Row(
                                                            //   children: [
                                                            //     DescriptionText(
                                                            //         descriptionText:
                                                            //             activeNearByGoodsDrivers[index]
                                                            //                 .vehicleName!),
                                                            //     SizedBox(
                                                            //       width: 10,
                                                            //     ),
                                                            //     selectedIndex ==
                                                            //             index
                                                            //         ? Icon(
                                                            //             Icons
                                                            //                 .info_outline,
                                                            //             size:
                                                            //                 18,
                                                            //           )
                                                            //         : SizedBox(),
                                                            //   ],
                                                            // ),

                                                            SubTitleText(
                                                                subTitle:
                                                                    '${activeNearByGoodsDrivers[index].vehicleWeight} Kg . ${activeNearByGoodsDrivers[index].arrivalTime!}'),
                                                            SubTitleText(
                                                                subTitle:
                                                                    'Base Fare . Rs.${activeNearByGoodsDrivers[index].basePrice!}/-'),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: HeadingText(
                                                      title:
                                                          "Rs.$formattedPrice/-"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Expanded(
                        child: RefreshIndicator(
                          onRefresh: (_handleRefresh),
                          child: Center(
                            child: Text(
                              'No nearby drivers are currently available.\nTry again',
                              style:
                                  nunitoSansStyle.copyWith(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
            SizedBox(
              height: kHeight + 100,
            ),
          ],
        ),
        bottomSheet: activeNearByGoodsDrivers.isNotEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                          saveBookingDetails();
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
                                      'Proceed with ${activeNearByGoodsDrivers[selectedIndex].vehicleName!}',
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
}
