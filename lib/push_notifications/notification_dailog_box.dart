import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();

    // Start timer to decrement progress and close dialog after 5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress -= 0.01; // Update progress
        if (_progress <= 0) {
          _timer.cancel();
          Navigator.of(context).pop(); // Auto-dismiss after 5 seconds
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Clean up timer
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                  "₹${widget.userRideRequestInformationModel!.totalPrice!.round()}/-",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                    "Total Distance : ${widget.userRideRequestInformationModel!.totalDistance!} km",
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                Text(
                    "Total Time : ${widget.userRideRequestInformationModel!.totalTime!}",
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.asset(
                                "assets/icons/green_dot.png",
                                width: 20,
                                height: 20,
                              ),
                            ),
                            Text(
                              "Pickup",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.green[900],
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 27.0),
                          child: Text(
                            widget.userRideRequestInformationModel!
                                .pickupAddress!,
                            style: nunitoSansStyle.copyWith(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow
                                .visible, // Adds ellipsis when text overflows
                            maxLines: 3, // Limits the text to a single line
                          ),
                        ),
                        SizedBox(
                          height: kHeight,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.asset(
                                "assets/icons/red_dot.png",
                                width: 20,
                                height: 20,
                              ),
                            ),
                            Text(
                              "Destination",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.red,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 27.0),
                          child: Text(
                            widget
                                .userRideRequestInformationModel!.dropAddress!,
                            style: nunitoSansStyle.copyWith(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow
                                .visible, // Adds ellipsis when text overflows
                            maxLines: 3, // Limits the text to a single line
                          ),
                        ),
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
  }

  acceptRideRequest(BuildContext context,
      UserRideRequestInformationModel userRideRequestInformationModel) async {
    _timer.cancel(); // Cancel the timer if "Accept" is clicked
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
          builder: (context) => NewTripScreen(),
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
