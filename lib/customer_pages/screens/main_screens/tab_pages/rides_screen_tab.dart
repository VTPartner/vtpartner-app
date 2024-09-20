import 'package:flutter/material.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/main_heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

import '../../../../routings/route_names.dart';
import '../../../../themes/themes.dart';
import '../../../../widgets/body_text1.dart';
import '../../../../widgets/circular_network_image.dart';
import '../../../../widgets/dotted_vertical_divider.dart';

class RidesScreenTabPage extends StatefulWidget {
  const RidesScreenTabPage({super.key});

  @override
  State<RidesScreenTabPage> createState() => _RidesScreenTabPageState();
}

class _RidesScreenTabPageState extends State<RidesScreenTabPage> {
  var noTripHistory = false;

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
                          SizedBox(
                            height: 280, // Adjust height based on your design
                            child: ListView.builder(
                              itemCount: 1, // Replace with your data length
                              itemBuilder: (context, index) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: (){
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
                                                              Text(
                                                                'Tata Ace',
                                                                style: nunitoSansStyle.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: ThemeClass
                                                                        .backgroundColorDark),
                                                              ),
                                                              Text(
                                                                '18 Aug 2024, 10:15 AM',
                                                                style: nunitoSansStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey),
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
                                                                      '2 Hours',
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
                                                                      '₹ 200'),
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
                                                                      'Cash'),
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
                                                                    "Shaheed Maniyar. 8296565587"),
                                                            SizedBox(
                                                              width: _width - 80,
                                                              child: BodyText1(
                                                                  text:
                                                                      "Plot No 83, Gat 765 Industrial Area phase"),
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
                                                                    "Arun Patil - 7654343376"),
                                                            SizedBox(
                                                              width: _width - 80,
                                                              child: BodyText1(
                                                                  text:
                                                                      "Q68R+PJ Ranjangaon, Ashtavinayak Mahamarg, Malthan Rd, Ranjangaon, Maharashtra 412209"),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                              thickness: 0.1,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom:12.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.person_2),
                                                  SizedBox(width: 5.0,),
                                                  Text(
                                                    "Driver arrived in",
                                                    style: nunitoSansStyle.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.fontSize),
                                                    overflow: TextOverflow.visible,
                                                  ),
                                                  SizedBox(width: 5.0,),
                                                  Text(
                                                    "15 mins",
                                                    style: nunitoSansStyle.copyWith(
                                                        color: ThemeClass.facebookBlue,
                                                        fontSize: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.fontSize),
                                                    overflow: TextOverflow.visible,
                                                  ),
                                                ],
                                              ),
                                            )
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
                          SizedBox(
                            height: _height -
                                230, // Adjust height based on your design
                            child: ListView.builder(
                              itemCount: 5, // Replace with your data length
                              itemBuilder: (context, index) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
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
                                                          Text(
                                                            'Tata Ace',
                                                            style: nunitoSansStyle.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: ThemeClass
                                                                    .backgroundColorDark),
                                                          ),
                                                          Text(
                                                            '18 Aug 2024, 10:15 AM',
                                                            style: nunitoSansStyle
                                                                .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey),
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
                                                                  '1 Hour | Completed',
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
                                                                  '₹ 3490'),
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
                                                            "assets/icons/amazon.png",
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                          SizedBox(
                                                            width: 2.0,
                                                          ),
                                                          DescriptionText(
                                                              descriptionText:
                                                                  'Amazon Pay'),
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
                                                                "Shaheed Maniyar. 8296565587"),
                                                        SizedBox(
                                                          width: _width - 80,
                                                          child: BodyText1(
                                                              text:
                                                                  "Plot No 83, Gat 765 Industrial Area phase"),
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
                                                                "Arun Patil - 7654343376"),
                                                        SizedBox(
                                                          width: _width - 80,
                                                          child: BodyText1(
                                                              text:
                                                                  "Q68R+PJ Ranjangaon, Ashtavinayak Mahamarg, Malthan Rd, Ranjangaon, Maharashtra 412209"),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                          thickness: 0.1,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom:12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.star,color: Colors.yellow[800],),
                                              SizedBox(width: 5.0,),
                                              Text(
                                                "Rate this Ride",
                                                style: nunitoSansStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.fontSize),
                                                overflow: TextOverflow.visible,
                                              ),
                                              
                                            ],
                                          ),
                                        )
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
