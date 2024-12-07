import 'dart:async';
import 'dart:ui' as ui;
import 'package:custom_info_window/custom_info_window.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vt_partner/themes/themes.dart';

class RideEndScreen extends StatefulWidget {
  const RideEndScreen({super.key});

  @override
  State<RideEndScreen> createState() => _RideEndScreenState();
}

class _RideEndScreenState extends State<RideEndScreen> {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(22.572645, 88.363892),
    zoom: 12.00,
  );

  LatLng location = const LatLng(22.610658, 88.400720);
  List<Marker> allMarkers = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            googlmap(),
            customInfoWindow(size),
            header(context),
            rideEndBottomsheet(size),
          ],
        ),
      ),
      // bottomSheet: rideEndBottomsheet(size),
    );
  }

  rideEndBottomsheet(Size size) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: Container(
            constraints: BoxConstraints(maxHeight: size.height * 0.8),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.4,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              builder: (context, ScrollController scrollController) {
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
                        blurRadius: 15,
                        offset: const Offset(10, 0),
                      ),
                    ],
                  ),
                  child: Column(
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
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: fixPadding * 2.0),
                          children: [
                            driverProfileImage(),
                            heightSpace,
                            const Text(
                              "Cameron Williamson",
                              style: semibold17Black,
                              textAlign: TextAlign.center,
                            ),
                            height5Space,
                            const Text(
                              "You Reached Destination",
                              style: regular14Grey,
                              textAlign: TextAlign.center,
                            ),
                            heightSpace,
                            heightSpace,
                            const Text(
                              "Trip Route",
                              style: bold18Black,
                            ),
                            heightSpace,
                            tripRouteAddress(),
                            heightSpace,
                            heightSpace,
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/rating');
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: double.maxFinite,
                                    height: 1,
                                    color: lightGreyColor,
                                  ),
                                  heightSpace,
                                  heightSpace,
                                  const Text(
                                    "How was your trip with Cameron?",
                                    style: bold18Black,
                                    textAlign: TextAlign.center,
                                  ),
                                  heightSpace,
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: fixPadding * 2.0),
                                    child: Text(
                                      "Your feedback will help us to improve driving experience better",
                                      textAlign: TextAlign.center,
                                      style: regular14Grey,
                                    ),
                                  ),
                                  heightSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: fixPadding / 4),
                                          child: Icon(
                                            Icons.star,
                                            color: Color(0xFFD2D2D2),
                                          ),
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            heightSpace,
                            heightSpace,
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  driverProfileImage() {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage("assets/driverDetail/Image.png"),
        ),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: fixPadding / 2),
            decoration: BoxDecoration(
              color: blackColor.withOpacity(0.35),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("4.7", style: bold12White),
                width5Space,
                Icon(
                  Icons.star,
                  size: 16,
                  color: yellowColor,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  tripRouteAddress() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: secondaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "9 Bailey Drive, Fredericton, NB E3B 5A3",
                        style: semibold15Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    widthSpace,
                    Text(
                      "11:20 am",
                      style: bold12Primary,
                    )
                  ],
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
          const Row(
            children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
                size: 20,
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "1655 Island Pkwy, Kamloops, BC V2B 6Y9",
                        style: semibold15Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    widthSpace,
                    Text(
                      "11:45 am",
                      style: bold12Primary,
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  customInfoWindow(Size size) {
    return CustomInfoWindow(
      controller: _customInfoWindowController,
      width: 100,
      height: 40,
      offset: 50,
    );
  }

  googlmap() {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow!();
      },
      onCameraMove: (position) {
        _customInfoWindowController.onCameraMove!();
      },
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: currentPosition,
      onMapCreated: mapCreated,
      markers: Set.from(allMarkers),
    );
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    _customInfoWindowController.googleMapController = controller;
    await marker();
    setState(() {});
  }

  marker() async {
    allMarkers.add(
      Marker(
        markerId: const MarkerId("drop location"),
        position: location,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor,
                border: Border.all(color: whiteColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "Island Pkwy",
                style: semibold12White,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            location,
          );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/bookNow/dropLocation.png", 130),
        ),
      ),
    );
    allMarkers.add(
      Marker(
        markerId: const MarkerId("location"),
        position: location,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor,
                border: Border.all(color: whiteColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "Island Pkwy",
                style: semibold12White,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            location,
          );
        },
        anchor: const Offset(0.5, 0.4),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/ridestart/cab.png", 55),
        ),
      ),
    );
  }

  header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: fixPadding, right: fixPadding, top: fixPadding * 5.0),
      child: Row(
        children: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_sharp,
              color: blackColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }
}
