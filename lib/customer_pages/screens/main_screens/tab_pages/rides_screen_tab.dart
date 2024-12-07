import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/all_bookings_model.dart';
import 'package:vt_partner/customer_pages/models/all_orders_model.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/main_heading_text.dart';
import 'package:vt_partner/widgets/shimmer_card.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

import '../../../../routings/route_names.dart';
import '../../../../themes/themes.dart';
import '../../../../widgets/body_text1.dart';
import '../../../../widgets/circular_network_image.dart';
import '../../../../widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/global/global.dart' as glb;

class RidesScreenTabPage extends StatefulWidget {
  const RidesScreenTabPage({super.key});

  @override
  State<RidesScreenTabPage> createState() => _RidesScreenTabPageState();
}

class _RidesScreenTabPageState extends State<RidesScreenTabPage> {
  var noTripHistory = false;
  var noBookingsFound = true;
  var noOrdersFound = true;
  var isLoading = true;
  List<AllBookingsModel> allBookingsModel = [];
  List<AllOrdersModel> allOrdersModel = [];

  Future<void> fetchAllBookings() async {
    final pref = await SharedPreferences.getInstance();
    var customer_id = pref.getString("customer_id");
    final data = {
      'customer_id': customer_id,
    };

    setState(() {
      isLoading = true;
      allBookingsModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/customers_all_bookings', data);
      if (kDebugMode) {
        // print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> bookingsData = response['results'];
        // Map the list of service data into a list of Service objects
        setState(() {
          allBookingsModel = bookingsData
              .map((serviceJson) => AllBookingsModel.fromJson(serviceJson))
              .toList();
          noBookingsFound = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        // glb.showToast("No Bookings Found.");
        setState(() {
          noBookingsFound = true;
        });
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAllOrders() async {
    final pref = await SharedPreferences.getInstance();
    var customer_id = pref.getString("customer_id");
    final data = {
      'customer_id': customer_id,
    };

    setState(() {
      isLoading = true;
      allOrdersModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/customers_all_orders', data);
      if (kDebugMode) {
        // print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> ordersData = response['results'];
        // Map the list of service data into a list of Service objects
        setState(() {
          allOrdersModel = ordersData
              .map((serviceJson) => AllOrdersModel.fromJson(serviceJson))
              .toList();
          noOrdersFound = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        // glb.showToast("No Orders History Found.");
        setState(() {
          noOrdersFound = true;
        });
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllBookings();
    fetchAllOrders();
  }
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemeClass.backgroundColorLightPink,
      body: SafeArea(
        child: noTripHistory
            ? Center(
                child:
                    DescriptionText(descriptionText: 'No Ride History Found'),
              )
            : isLoading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.2),
                        highlightColor: Colors.grey.withOpacity(0.1),
                        enabled: isLoading,
                        child: const VTPartnerLoader(),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MainHeadingText(title: 'My Rides'),
                    ),
                    // Heading for Current Trips
                    Visibility(
                      visible: true,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DescriptionText(
                                        descriptionText: 'Ongoing')),
                              ],
                            ),
                          ),

                          // ListView for Current Trips
                              noBookingsFound
                                  ? Center(
                                      child: DescriptionText(
                                          descriptionText: 'No Bookings Found'),
                                    )
                                  : SizedBox(
                            height: 280, // Adjust height based on your design
                            child: ListView.builder(
                                        itemCount: allBookingsModel
                                            .length, // Replace with your data length
                              itemBuilder: (context, index) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: (){
                                                glb.booking_id =
                                                    allBookingsModel[index]
                                                        .booking_id!;
                                      Navigator.pushNamed(
                                            context, CustomerOngoingRideDetailsRoute);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 6.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                  left: 4.0,
                                                  right: 4.0,
                                                  bottom: 2.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(12.0)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  left: 8.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                                        Row(
                                                                          children: [
                                                                            CircleAvatar(
                                                                              radius: 30,
                                                                              backgroundColor: Colors.white,
                                                                              child: ClipOval(
                                                                                child: Image.network(
                                                                                  "${allBookingsModel[index].vehicle_image}",
                                                                                  fit: BoxFit.contain,
                                                                                  width: 50,
                                                                                  height: 50,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 8.0),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    allBookingsModel[index].vehicle_name!,
                                                                                    style: nunitoSansStyle.copyWith(fontWeight: FontWeight.bold, color: ThemeClass.backgroundColorDark),
                                                                                  ),
                                                                                  Text(
                                                                                    glb.formatEpochToDateTime(double.parse(allBookingsModel[index].booking_timing!)),
                                                                                    style: nunitoSansStyle.copyWith(fontSize: 12, color: Colors.grey),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                              const SizedBox(
                                                                height: 5.0,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            26.0,
                                                                        vertical:
                                                                            4.0),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                26.0),
                                                                    color: ThemeClass
                                                                        .facebookBlue),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                                allBookingsModel[index].total_time!,
                                                                                style: nunitoSansStyle.copyWith(
                                                                                  fontWeight: FontWeight.w700,
                                                                                  color: Colors.white,
                                                                                  fontSize: 12.0,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                " | ${allBookingsModel[index].booking_status!}",
                                                                      style: nunitoSansStyle
                                                                          .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12.0,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              DescriptionText(
                                                                  descriptionText:
                                                                                "₹ ${allBookingsModel[index].total_price!}/-"),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                color: Colors.grey,
                                                                size: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Image.asset(
                                                                "assets/icons/cash.png",
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              SizedBox(
                                                                width: 2.0,
                                                              ),
                                                              DescriptionText(
                                                                  descriptionText:
                                                                                allBookingsModel[index].payment_method!),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                              thickness: 0.1,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16.0,
                                                bottom: 8.0,
                                              ),
                                              child: Container(
                                                width: _width,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(12.0)),
                                                ),
                                                child: Column(
                                                  children: [
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
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Pickup",
                                                              style: nunitoSansStyle
                                                                  .copyWith(
                                                                      color: Colors
                                                                              .green[
                                                                          900],
                                                                      fontSize: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodySmall
                                                                          ?.fontSize),
                                                              overflow: TextOverflow
                                                                  .visible,
                                                            ),
                                                            DescriptionText(
                                                                descriptionText:
                                                                              "${allBookingsModel[index].sender_name!}. ${allBookingsModel[index].sender_number!}"),
                                                            SizedBox(
                                                              width: _width - 80,
                                                              child: BodyText1(
                                                                  text:
                                                                                allBookingsModel[index].pickup_address!),
                                                            ),
                                                            SizedBox(
                                                              height: kHeight,
                                                            ),
                                                            Text(
                                                              "Destination",
                                                              style: nunitoSansStyle
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodySmall
                                                                          ?.fontSize),
                                                              overflow: TextOverflow
                                                                  .visible,
                                                            ),
                                                            DescriptionText(
                                                                descriptionText:
                                                                              "${allBookingsModel[index].receiver_name!}. ${allBookingsModel[index].receiver_number!}"),
                                                            SizedBox(
                                                              width: _width - 80,
                                                              child: BodyText1(
                                                                  text:
                                                                                allBookingsModel[index].drop_address!),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                                      // Divider(
                                                      //   color: Colors.grey,
                                                      //   thickness: 0.1,
                                                      // ),
                                                      // Padding(
                                                      //   padding: const EdgeInsets.only(bottom:12.0),
                                                      //   child: Row(
                                                      //     mainAxisAlignment:
                                                      //         MainAxisAlignment.center,
                                                      //     children: [
                                                      //       Icon(Icons.person_2),
                                                      //       SizedBox(width: 5.0,),
                                                      //       Text(
                                                      //         "Driver arrived in",
                                                      //         style: nunitoSansStyle.copyWith(
                                                      //           fontWeight: FontWeight.bold,
                                                      //             color: Colors.black,
                                                      //             fontSize: Theme.of(context)
                                                      //                 .textTheme
                                                      //                 .bodyMedium
                                                      //                 ?.fontSize),
                                                      //         overflow: TextOverflow.visible,
                                                      //       ),
                                                      //       SizedBox(width: 5.0,),
                                                      //       Text(
                                                      //         "15 mins",
                                                      //         style: nunitoSansStyle.copyWith(
                                                      //             color: ThemeClass.facebookBlue,
                                                      //             fontSize: Theme.of(context)
                                                      //                 .textTheme
                                                      //                 .bodyMedium
                                                      //                 ?.fontSize),
                                                      //         overflow: TextOverflow.visible,
                                                      //       ),
                                                      //     ],
                                                      //   ),
                                                      // )
                                         
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                    // Heading for Past Trips
                    Visibility(
                      visible: true,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DescriptionText(
                                        descriptionText: 'Previous')),
                              ],
                            ),
                          ),

                          // ListView for Past Trips
                              noOrdersFound
                                  ? Center(
                                      child: DescriptionText(
                                          descriptionText:
                                              'Orders not yet completed'),
                                    )
                                  : SizedBox(
                            height: _height -
                                230, // Adjust height based on your design
                            child: ListView.builder(
                                        itemCount: allOrdersModel
                                            .length, // Replace with your data length
                              itemBuilder: (context, index) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                                  glb.order_id =
                                                      allOrdersModel[index]
                                                          .order_id!;
                                                  print(
                                                      "order_id::${glb.order_id}");
                                      Navigator.pushNamed(
                                          context, CustomerCompletedRideDetailsRoute);
                                    },
                                    child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4.0)),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              left: 4.0,
                                              right: 4.0,
                                              bottom: 2.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12.0)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              CircleAvatar(
                                                                                radius: 30,
                                                                                backgroundColor: Colors.white,
                                                                                child: ClipOval(
                                                                                  child: Image.network(
                                                                                    "${allOrdersModel[index].vehicle_image}",
                                                                                    fit: BoxFit.contain,
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 8.0),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      allOrdersModel[index].vehicle_name!,
                                                                                      style: nunitoSansStyle.copyWith(fontWeight: FontWeight.bold, color: ThemeClass.backgroundColorDark),
                                                                                    ),
                                                                                    Text(
                                                                                      glb.formatEpochToDateTime(double.parse(allOrdersModel[index].booking_timing!)),
                                                                                      style: nunitoSansStyle.copyWith(fontSize: 12, color: Colors.grey),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                          const SizedBox(
                                                            height: 5.0,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        26.0,
                                                                    vertical:
                                                                        4.0),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            26.0),
                                                                color: Colors.green[900]),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                                  '${allOrdersModel[index].total_time} | Completed',
                                                                  style: nunitoSansStyle
                                                                      .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12.0,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          DescriptionText(
                                                              descriptionText:
                                                                              '₹ ${allOrdersModel[index].total_price!}/-'),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.grey,
                                                            size: 10,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                                            "assets/icons/cash.png",
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                          SizedBox(
                                                            width: 2.0,
                                                          ),
                                                          DescriptionText(
                                                              descriptionText:
                                                                              allOrdersModel[index].payment_method!),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                          thickness: 0.1,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            bottom: 8.0,
                                          ),
                                          child: Container(
                                            width: _width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12.0)),
                                            ),
                                            child: Column(
                                              children: [
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
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Pickup",
                                                          style: nunitoSansStyle
                                                              .copyWith(
                                                                  color: Colors
                                                                          .green[
                                                                      900],
                                                                  fontSize: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodySmall
                                                                      ?.fontSize),
                                                          overflow: TextOverflow
                                                              .visible,
                                                        ),
                                                        DescriptionText(
                                                            descriptionText:
                                                                                "${allOrdersModel[index].sender_name!} - ${allOrdersModel[index].sender_number!}"),
                                                        SizedBox(
                                                          width: _width - 80,
                                                          child: BodyText1(
                                                              text:
                                                                              allOrdersModel[index].pickup_address!),
                                                        ),
                                                        SizedBox(
                                                          height: kHeight,
                                                        ),
                                                        Text(
                                                          "Destination",
                                                          style: nunitoSansStyle
                                                              .copyWith(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodySmall
                                                                      ?.fontSize),
                                                          overflow: TextOverflow
                                                              .visible,
                                                        ),
                                                        DescriptionText(
                                                            descriptionText:
                                                                                "${allOrdersModel[index].receiver_name!} - ${allOrdersModel[index].receiver_number!}"),
                                                        SizedBox(
                                                          width: _width - 80,
                                                          child: BodyText1(
                                                              text:
                                                                              allOrdersModel[index].drop_address!),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                                        // Divider(
                                                        //   color: Colors.grey,
                                                        //   thickness: 0.1,
                                                        // ),
                                                        // Padding(
                                                        //   padding: const EdgeInsets.only(bottom:12.0),
                                                        //   child: Row(
                                                        //     mainAxisAlignment:
                                                        //         MainAxisAlignment.center,
                                                        //     children: [
                                                        //       Icon(Icons.star,color: Colors.yellow[800],),
                                                        //       SizedBox(width: 5.0,),
                                                        //       Text(
                                                        //         "Rate this Ride",
                                                        //         style: nunitoSansStyle.copyWith(
                                                        //           fontWeight: FontWeight.bold,
                                                        //             color: Colors.black,
                                                        //             fontSize: Theme.of(context)
                                                        //                 .textTheme
                                                        //                 .bodyMedium
                                                        //                 ?.fontSize),
                                                        //         overflow: TextOverflow.visible,
                                                        //       ),
                                              
                                                        //     ],
                                                        //   ),
                                                        // )
                                      ],
                                    ),
                                  ),
                                )
                             ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
