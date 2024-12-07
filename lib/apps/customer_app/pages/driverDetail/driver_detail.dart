import 'dart:ui' as ui;
import 'package:custom_info_window/custom_info_window.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vt_partner/apps/constants/key.dart';
import 'package:vt_partner/themes/themes.dart';

class DriverDetailScreen extends StatefulWidget {
  const DriverDetailScreen({super.key});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(22.572645, 88.363892),
    zoom: 12.00,
  );

  LatLng endLocation = const LatLng(22.610658, 88.400720);
  LatLng startLocation = const LatLng(22.555501, 88.347469);
  List<Marker> allMarkers = [];
  Map<PolylineId, Polyline> polylines = {};

  bool isMoreInfo = false;

  @override
  void initState() {
    getDirections();
    super.initState();
  }

  Future<void> getDirections() async {
    List<LatLng> polylineCoordinates = [];

    // Create the request object
    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(startLocation.latitude, startLocation.longitude),
      destination: PointLatLng(endLocation.latitude, endLocation.longitude),
      wayPoints: [PolylineWayPoint(location: 'Kolkata')],
      mode: TravelMode.transit,
    );

    // Get the route
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: request, googleApiKey: googleMapApiKey);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: primaryColor,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          googlmap(),
          customInfoWindow(size),
          header(context),
          driverDetailBottomsheet(size),
        ],
      ),
    );
  }

  customInfoWindow(Size size) {
    return CustomInfoWindow(
      controller: _customInfoWindowController,
      width: size.width * 0.7,
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
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  driverDetailBottomsheet(Size size) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: BottomSheet(
            backgroundColor: Colors.transparent,
            enableDrag: false,
            constraints: BoxConstraints(maxHeight: size.height - 100),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
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
                      blurRadius: 15,
                      offset: const Offset(10, 0),
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
                    isMoreInfo
                        ? Expanded(
                            child: driverDetailList(),
                          )
                        : driverDetailList(),
                    moreLessAndcancelButton()
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  driverDetailList() {
    return ListView(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        callMessageDriveInfo(),
        heightSpace,
        const Text(
          "Cameron Williamson",
          style: semibold17Black,
          textAlign: TextAlign.center,
        ),
        heightSpace,
        heightSpace,
        cabNumberAndArriving(),
        isMoreInfo
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  titleRowWidget("Trip Route", "10 km (15 min)"),
                  heightSpace,
                  pickupDropLocation(),
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  titleRowWidget("Payments", "\$30.50"),
                  heightSpace,
                  paymentMethod(),
                  heightSpace,
                  heightSpace,
                  divider(),
                  heightSpace,
                  heightSpace,
                  const Text(
                    "Other Info",
                    style: bold18Black,
                  ),
                  heightSpace,
                  Row(
                    children: [
                      otherItemWidget("Payment via", "Wallet"),
                      otherItemWidget("Ride fare", "\$30.50"),
                      otherItemWidget("Ride type", "Mini")
                    ],
                  )
                ],
              )
            : const SizedBox(),
      ],
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

  cabNumberAndArriving() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                "Swift Dezire",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "GJ 5 AB 1265",
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
                "Arriving in",
                style: regular14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "3 mins",
                style: semibold15Black,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        )
      ],
    );
  }

  callMessageDriveInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: whiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 4),
              )
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.call,
            color: primaryColor,
            size: 16,
          ),
        ),
        widthSpace,
        widthSpace,
        Container(
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
        ),
        widthSpace,
        widthSpace,
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/chatWithDriver');
          },
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: whiteColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.ellipses_bubble_fill,
              color: primaryColor,
              size: 16,
            ),
          ),
        )
      ],
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
            "assets/payment/wallet.png",
            height: 40,
            width: 40,
          ),
          widthSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "**** **** **56 7896",
                  style: semibold16Black,
                ),
                Text(
                  "Wallet",
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
                child: Text(
                  "9 Bailey Drive, Fredericton, NB E3B 5A3",
                  style: semibold15Black,
                  overflow: TextOverflow.ellipsis,
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
                child: Text(
                  "1655 Island Pkwy, Kamloops, BC V2B 6Y9",
                  style: semibold15Black,
                  overflow: TextOverflow.ellipsis,
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

  divider() {
    return Container(
      height: 1,
      width: double.maxFinite,
      color: lightGreyColor,
    );
  }

  moreLessAndcancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 2.0),
      child: Row(
        children: [
          TextButton.icon(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(
                primaryColor.withOpacity(0.1),
              ),
            ),
            onPressed: () {
              setState(() {
                isMoreInfo = !isMoreInfo;
              });
            },
            icon: Icon(
              isMoreInfo
                  ? Icons.keyboard_arrow_down_outlined
                  : Icons.keyboard_arrow_up_outlined,
              color: primaryColor,
            ),
            label: Text(
              isMoreInfo ? "Less" : "More",
              style: bold16Black,
            ),
          ),
          widthSpace,
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/rideStart');
              },
              child: Container(
                padding: const EdgeInsets.all(fixPadding * 1.3),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: buttonShadow,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Cancel Ride",
                  style: bold18White,
                ),
              ),
            ),
          )
        ],
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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_sharp,
              color: blackColor,
            ),
          ),
          const Expanded(
            child: Text(
              "Driver Detail",
              style: extrabold20Black,
            ),
          )
        ],
      ),
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
        position: endLocation,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ]),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "10km",
                      style: bold10White,
                    ),
                  ),
                  widthSpace,
                  const Expanded(
                    child: Text(
                      "1655 Island Pkwy, Kamloops, BC V2B 6Y9",
                      style: semibold14Black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            endLocation,
          );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/bookNow/dropLocation.png", 130),
        ),
      ),
    );
    allMarkers.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: startLocation,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: fixPadding),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ]),
              alignment: Alignment.center,
              child: const Text(
                "9 Bailey Drive, Fredericton, NB E3B 5A3",
                style: semibold14Black,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            startLocation,
          );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/bookNow/currentLocation.png", 60),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }
}
