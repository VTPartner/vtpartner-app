import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/newRide/new_ride_details.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'dart:async';
import 'package:vt_partner/delivery_agent_pages/models/user_ride_request_information.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/global/global.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/delivery_agent_pages/screens/new_trip_screen/new_trip_screen.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformationModel? userRideRequestInformationModel;
  String? bookingId;
  NotificationDialogBox(
      {super.key, this.userRideRequestInformationModel, this.bookingId});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  late Timer _timer;
  double _progress = 1.0;
  late AudioPlayer _audioPlayer;
  bool isShowMore = true;

  int _remainingTime = 15; // Total countdown time in seconds

  @override
  void initState() {
    super.initState();
    // Initialize AudioPlayer
    _audioPlayer = AudioPlayer();
    _playSound();
    // Start timer to decrement progress and close dialog after 15 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _progress -= 0.01; // Update progress
        if (_progress <= 0) {
          _timer.cancel();
          _stopSound();
          // Navigator.of(context).pop(); // Auto-dismiss after 5 seconds
        } else {
          // Update remaining time every second
          _remainingTime = (_progress * 15).ceil();
        }
      });
    });
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('audio/sound.mp3'));
  }

  void _stopSound() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _timer.cancel(); // Clean up timer
    _stopSound();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _oldDialogBox(double width) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: _progress,
              minHeight: 5.0,
              color: Colors.green,
              backgroundColor: Colors.grey[300],
            ),

            const SizedBox(
              height: 14,
            ),

            Image.asset(
              "assets/images/logo_new.png",
              width: 160,
            ),

            const SizedBox(
              height: 10,
            ),

            //title
            const Text(
              "New Ride Request",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.grey),
            ),

            const SizedBox(height: 14.0),

            //addresses origin destination
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 8.0,
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
                              Text(
                                "Pickup",
                                style: nunitoSansStyle.copyWith(
                                    color: Colors.green[900],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.fontSize),
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(
                                width: width - 160,
                                child: Text(
                                  widget.userRideRequestInformationModel!
                                      .pickupAddress!,
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey, fontSize: 12.0),
                                  overflow: TextOverflow
                                      .visible, // Adds ellipsis when text overflows
                                  maxLines:
                                      3, // Limits the text to a single line
                                ),
                              ),
                              SizedBox(
                                height: kHeight,
                              ),
                              Text(
                                "Destination",
                                style: nunitoSansStyle.copyWith(
                                    color: Colors.red,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.fontSize),
                                overflow: TextOverflow.visible,
                              ),
                              SizedBox(
                                width: width - 160,
                                child: Text(
                                  widget.userRideRequestInformationModel!
                                      .dropAddress!,
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey, fontSize: 12.0),
                                  overflow: TextOverflow
                                      .visible, // Adds ellipsis when text overflows
                                  maxLines:
                                      3, // Limits the text to a single line
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //buttons cancel accept
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    acceptRideRequest(
                        context, widget.userRideRequestInformationModel!!);
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
                                'Accept',
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
            ),
          ],
        ),
      ),
    );
  }

  void _showRideRequestDailog(
      String amount, double width, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoTheme(
              data: CupertinoThemeData(brightness: Brightness.light),
              child: CupertinoAlertDialog(
                title: Text("New Ride Request"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    // Progress Indicator
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 5.0,
                      color: Colors.green,
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: 8),
                    Text("Fare Price:", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text(
                      "₹$amount/-",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text("Select Payment Type:",
                        style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    Column(
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
                                Text(
                                  "Pickup",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.green[900],
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                SizedBox(
                                  width: width - 160,
                                  child: Text(
                                    widget.userRideRequestInformationModel!
                                        .pickupAddress!,
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.grey, fontSize: 12.0),
                                    overflow: TextOverflow
                                        .visible, // Adds ellipsis when text overflows
                                    maxLines:
                                        3, // Limits the text to a single line
                                  ),
                                ),
                                SizedBox(
                                  height: kHeight,
                                ),
                                Text(
                                  "Destination",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.red,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize),
                                  overflow: TextOverflow.visible,
                                ),
                                SizedBox(
                                  width: width - 160,
                                  child: Text(
                                    widget.userRideRequestInformationModel!
                                        .dropAddress!,
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.grey, fontSize: 12.0),
                                    overflow: TextOverflow
                                        .visible, // Adds ellipsis when text overflows
                                    maxLines:
                                        3, // Limits the text to a single line
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text("Accept"),
                    onPressed: () {
                      acceptRideRequest(
                          context, widget.userRideRequestInformationModel!!);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  passengerDetailsBottomSheet(ui.Size size) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: BottomSheet(
            enableDrag: false,
            constraints: BoxConstraints(maxHeight: size.height - 100),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            backgroundColor: Colors.transparent,
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
                        color: blackColor.withOpacity(0.25), blurRadius: 6)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    heightSpace,
                    heightSpace,
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    heightSpace,
                    isShowMore
                        ? Expanded(
                            child: passengerDetails(context),
                          )
                        : passengerDetails(context),
                    acceptRejectAndLessMoreButtons(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  acceptRejectAndLessMoreButtons() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              acceptRideRequest(
                  context, widget.userRideRequestInformationModel!);
            },
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.3),
              color: primaryColor,
              alignment: Alignment.center,
              child: const Text(
                "Accept",
                style: bold18White,
              ),
            ),
          ),
        ),
        widthBox(3),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                isShowMore = !isShowMore;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.3),
              color: primaryColor,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isShowMore
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: whiteColor,
                  ),
                  width5Space,
                  Text(
                    isShowMore ? "Less" : "More",
                    style: bold18White,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  passengerDetails(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      children: [
        passangerProfileImage(context),
        heightSpace,
        Text(
          "${widget.userRideRequestInformationModel!.customerName}",
          style: semibold17Black,
          textAlign: TextAlign.center,
        ),
        heightSpace,
        rideFareAndDistance(),
        isShowMore
            ? Column(
                children: [
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  titleRowWidget("Trip Route",
                      "${widget.userRideRequestInformationModel!.totalDistance} km (${widget.userRideRequestInformationModel!.totalTime})"),
                  heightSpace,
                  heightSpace,
                  pickupDropLocation(),
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  titleRowWidget("Payments",
                      "\₹ ${widget.userRideRequestInformationModel!.totalPrice!.round()}"),
                  heightSpace,
                  paymentMethod(),
                  // heightSpace,
                  // heightSpace,
                  // divider(),
                  // heightSpace,
                  // heightSpace,
                  // const Text(
                  //   "Other Info",
                  //   style: bold18Black,
                  // ),
                  // heightSpace,
                  // Row(
                  //   children: [
                  //     otherItemWidget("Payment via", "Wallet"),
                  //     otherItemWidget("Ride fare", "\$30.50"),
                  //     otherItemWidget("Ride type",
                  //         "${widget.userRideRequestInformationModel!.totalPrice!.round()}")
                  //   ],
                  // ),
                  // heightSpace,
                ],
              )
            : const SizedBox(),
      ],
    );
  }

  divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: fixPadding / 4),
      width: double.maxFinite,
      color: lightGreyColor,
    );
  }

  otherItemWidget(title, content) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: semibold14Grey,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            content,
            style: bold15Black,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  paymentMethod() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: lightGreyColor),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/home/wallet.png",
            height: 40,
            width: 40,
          ),
          widthSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   "**** **** **56 7896",
                //   style: semibold16Black,
                // ),
                Text(
                  "Payment Post Delivery",
                  style: semibold12Grey,
                )
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: secondaryColor)
        ],
      ),
    );
  }

  pickupDropLocation() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: secondaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Text(
                  widget.userRideRequestInformationModel!.pickupAddress!,
                  style: semibold14Black,
                  overflow: TextOverflow.visible,
                ),
              )
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: fixPadding),
                child: DottedBorder(
                  padding: EdgeInsets.zero,
                  strokeWidth: 1.2,
                  dashPattern: const [1, 3],
                  color: blackColor,
                  strokeCap: StrokeCap.round,
                  child: Container(
                    height: 40,
                  ),
                ),
              ),
              widthSpace,
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  height: 1,
                  color: lightGreyColor,
                ),
              )
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Text(
                  widget.userRideRequestInformationModel!
                                .dropAddress!,
                  style: semibold14Black,
                  overflow: TextOverflow.visible,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  titleRowWidget(text1, text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text1,
            style: bold18Black,
          ),
        ),
        Text(
          text2,
          style: bold14Primary,
        )
      ],
    );
  }

  rideFareAndDistance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                "Ride fare",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "\₹ ${widget.userRideRequestInformationModel!.totalPrice!.round()}",
                style: semibold15Black,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                "Location distance",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${widget.userRideRequestInformationModel!.totalDistance} Km",
                style: semibold15Black,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        )
      ],
    );
  }

  passangerProfileImage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widthSpace,
        widthSpace,
        Container(
          clipBehavior: Clip.hardEdge,
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image:
                  NetworkImage("https://vtpartner.org/media/image_YoRjcDi.jpg"),
            ),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 6,
              )
            ],
          ),
        ),
        widthSpace,
        widthSpace,
     
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   double width = MediaQuery.of(context).size.width;
  //   double height = MediaQuery.of(context).size.height;
  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       return CupertinoTheme(
  //         data: CupertinoThemeData(brightness: Brightness.light),
  //         child: CupertinoAlertDialog(
  //           title: Text("New Ride Request"),
  //           content: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(height: 8),
  //               // Progress Indicator
  //               LinearProgressIndicator(
  //                 value: _progress,
  //                 minHeight: 5.0,
  //                 color: Colors.green,
  //                 backgroundColor: Colors.grey[300],
  //               ),
  //               SizedBox(height: 8),
  //               Text("Fare Price:", style: TextStyle(fontSize: 14)),
  //               SizedBox(height: 4),
  //               Text(
  //                 "₹${widget.userRideRequestInformationModel!.totalPrice!.round()}/-",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: CupertinoColors.activeBlue,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               Text(
  //                   "Total Distance : ${widget.userRideRequestInformationModel!.totalDistance!} km",
  //                   style: TextStyle(fontSize: 14)),
  //               SizedBox(height: 8),
  //               Text(
  //                   "Total Time : ${widget.userRideRequestInformationModel!.totalTime!}",
  //                   style: TextStyle(fontSize: 14)),
  //               SizedBox(height: 16),

  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   SizedBox(
  //                     height: 5.0,
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Padding(
  //                             padding: const EdgeInsets.only(right: 8.0),
  //                             child: Image.asset(
  //                               "assets/icons/green_dot.png",
  //                               width: 20,
  //                               height: 20,
  //                             ),
  //                           ),
  //                           Text(
  //                             "Pickup",
  //                             style: nunitoSansStyle.copyWith(
  //                                 color: Colors.green[900],
  //                                 fontSize: Theme.of(context)
  //                                     .textTheme
  //                                     .bodyLarge
  //                                     ?.fontSize),
  //                             overflow: TextOverflow.visible,
  //                           ),
  //                         ],
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 27.0),
  //                         child: Text(
  //                           widget.userRideRequestInformationModel!
  //                               .pickupAddress!,
  //                           style: nunitoSansStyle.copyWith(
  //                               fontSize: 14.0, fontWeight: FontWeight.bold),
  //                           textAlign: TextAlign.left,
  //                           overflow: TextOverflow
  //                               .visible, // Adds ellipsis when text overflows
  //                           maxLines: 3, // Limits the text to a single line
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         height: kHeight,
  //                       ),
  //                       Row(
  //                         children: [
  //                           Padding(
  //                             padding: const EdgeInsets.only(right: 8.0),
  //                             child: Image.asset(
  //                               "assets/icons/red_dot.png",
  //                               width: 20,
  //                               height: 20,
  //                             ),
  //                           ),
  //                           Text(
  //                             "Destination",
  //                             style: nunitoSansStyle.copyWith(
  //                                 color: Colors.red,
  //                                 fontSize: Theme.of(context)
  //                                     .textTheme
  //                                     .bodyLarge
  //                                     ?.fontSize),
  //                             overflow: TextOverflow.visible,
  //                           ),
  //                         ],
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 27.0),
  //                         child: Text(
  //                           widget
  //                               .userRideRequestInformationModel!.dropAddress!,
  //                           style: nunitoSansStyle.copyWith(
  //                               fontSize: 14.0, fontWeight: FontWeight.bold),
  //                           textAlign: TextAlign.left,
  //                           overflow: TextOverflow
  //                               .visible, // Adds ellipsis when text overflows
  //                           maxLines: 3, // Limits the text to a single line
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             CupertinoDialogAction(
  //               child: Text("Accept"),
  //               onPressed: () {
  //                 acceptRideRequest(
  //                     context, widget.userRideRequestInformationModel!!);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return StatefulBuilder(
      builder: (context, setState) {
        return Material(
          child: SafeArea(
            child: Stack(
              // Add a Stack here
              children: [
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: AnimationConfiguration.synchronized(
                    child: SlideAnimation(
                      curve: Curves.easeIn,
                      delay: const Duration(milliseconds: 350),
                      child: BottomSheet(
                        enableDrag: false,
                        constraints:
                            BoxConstraints(maxHeight: size.height - 100),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        backgroundColor: Colors.transparent,
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
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                heightSpace,
                                heightSpace,
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                heightSpace,
                                heightSpace,
                                const Text(
                                  "Ride Request Received",
                                  style: bold18Primary,
                                ),
                                heightSpace,
                                Text(
                                  "$_remainingTime sec left",
                                  style: bold16Black,
                                ),
                                heightSpace,
                                isShowMore
                                    ? Expanded(
                                        child: passengerDetails(context),
                                      )
                                    : passengerDetails(context),
                                acceptRejectAndLessMoreButtons(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  acceptRideRequest(BuildContext context,
      UserRideRequestInformationModel userRideRequestInformationModel) async {
    _timer.cancel(); // Cancel the timer if "Accept" is clicked
    _stopSound();
    _audioPlayer.dispose();
    try {
      final pref = await SharedPreferences.getInstance();
      var driver_id = pref.getString("goods_driver_id");
      GetServerKey getServerKey = GetServerKey();
      String accessToken = await getServerKey.getServerKeyToken();
      print("serverKeyToken::$accessToken");
      if (accessToken.isEmpty) {
        showToast("No Token Found!");
        return;
      }

      final data = {
        'booking_id': widget.bookingId!,
        'driver_id': driver_id,
        'server_token': accessToken,
        'customer_id': userRideRequestInformationModel.customerId
      };

      final response = await RequestAssistant.postRequest(
          '${serverEndPoint}/goods_driver_booking_accepted', data);
      if (kDebugMode) {
        print(response);
      }
      AssistantMethods.pauseLiveLocationUpdates();
      //trip started now - send driver to new tripScreen
      print(
          "userRideRequestInformationModel::$userRideRequestInformationModel");
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => GoodsRiderNewRideDetails(),
        ),
        (route) => false, // This removes all previous routes
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        showToast(
            "Already Assigned to Another Driver.\n Please be quick at receiving ride requests to earn more.");
        Navigator.pop(context);
      } else {
        //glb.showToast("An error occurred while fetching booking details");
        // glb.showToast("An error occurred while fetching booking details: ${e.toString()}");
      }
    }
    //Navigator.of(context).pop(); // Dismiss the dialog
    // FirebaseDatabase.instance.ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .child("newRideStatus")
    //     .once()
    //     .then((snap)
    // {
    //   if(snap.snapshot.value != null)
    //   {
    //     getRideRequestId = snap.snapshot.value.toString();
    //   }
    //   else
    //   {
    //     Fluttertoast.showToast(msg: "This ride request do not exists.");
    //   }

    //   if(getRideRequestId == widget.userRideRequestDetails!.rideRequestId)
    //   {
    //     FirebaseDatabase.instance.ref()
    //         .child("drivers")
    //         .child(currentFirebaseUser!.uid)
    //         .child("newRideStatus")
    //         .set("accepted");

    //     AssistantMethods.pauseLiveLocationUpdates();

    //     //trip started now - send driver to new tripScreen
    //     Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripScreen(
    //         userRideRequestDetails: widget.userRideRequestDetails,
    //     )));
    //   }
    //   else
    //   {
    //     Fluttertoast.showToast(msg: "This Ride Request do not exists.");
    //   }
    // });
  }
}
