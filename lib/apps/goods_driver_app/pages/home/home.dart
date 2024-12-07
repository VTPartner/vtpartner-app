import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:custom_info_window/custom_info_window.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:vt_partner/themes/themes.dart';

class GoodsDriverHomeScreen extends StatefulWidget {
  const GoodsDriverHomeScreen({super.key, this.isonline});

  final bool? isonline;

  @override
  State<GoodsDriverHomeScreen> createState() => _GoodsDriverHomeScreenState();
}

class _GoodsDriverHomeScreenState extends State<GoodsDriverHomeScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PolylinePoints polylinePoints = PolylinePoints();
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  DateTime? backpressTime;

  bool isOnline = false;

  GoogleMapController? mapController;

  LatLng endLocation = const LatLng(22.610658, 88.400720);
  LatLng startLocation = const LatLng(22.555501, 88.347469);

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(22.572645, 88.363892),
    zoom: 12.00,
  );

  List<Marker> allMarkers = [];
  List<Marker> onlineallMarkers = [];
  Map<PolylineId, Polyline> polylines = {};

  bool isShowMore = false;

  @override
  void initState() {
    // getDirections();
    setState(() {
      isOnline = widget.isonline ?? false;
    });
    super.initState();
  }

  // getDirections() async {
  //   List<LatLng> polylineCoordinates = [];

  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       googleMapApiKey,
  //       PointLatLng(startLocation.latitude, startLocation.longitude),
  //       PointLatLng(endLocation.latitude, endLocation.longitude),
  //       travelMode: TravelMode.driving,
  //       wayPoints: [PolylineWayPoint(location: 'Kolkata')]);

  //   if (result.points.isNotEmpty) {
  //     for (var point in result.points) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     }
  //   }
  //   addPolyLine(polylineCoordinates);
  // }

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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        bool backStatus = onWillpop(context);
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: drawer(size),
        body: isOnline
            ? Stack(
                children: [
                  onlinegoogleMap(),
                  customInfoWindow(size),
                  onlineTopheader(),
                  passangerDetailBottomSheet(size)
                ],
              )
            : Stack(
                children: [
                  googleMap(),
                  currentLoationBox(),
                  goOnlineButton(),
                ],
              ),
        floatingActionButton: isOnline ? null : currentLocationButton(),
      ),
    );
  }

  passangerDetailBottomSheet(ui.Size size) {
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
                            child: passangerDetail(context),
                          )
                        : passangerDetail(context),
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
              Navigator.pushNamed(context, '/gotoPickup');
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
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.3),
              color: primaryColor,
              alignment: Alignment.center,
              child: const Text(
                "Reject",
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

  passangerDetail(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      children: [
        passangerProfileImage(context),
        heightSpace,
        const Text(
          "Tynisha Obey",
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
                  titleRowWidget("Trip Route", "10 km (15 min)"),
                  heightSpace,
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
                  ),
                  heightSpace,
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

  rideFareAndDistance() {
    return const Row(
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
                "\$22.50",
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
                "10km",
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
              image: AssetImage("assets/home/passanger.png"),
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
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/chat');
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

  onlineTopheader() {
    return Padding(
      padding: EdgeInsets.only(
          top: (Platform.isIOS) ? fixPadding * 6.0 : fixPadding * 4.0,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
                child: menuButton(whiteColor),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isOnline = !isOnline;
                  });
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: fixPadding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: primaryColor,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Go Offline",
                    style: bold18White,
                  ),
                ),
              )
            ],
          ),
          heightSpace,
          const Text(
            "Ride Request Received",
            style: bold18Primary,
          ),
          const Text(
            "0:30 sec left",
            style: bold16Black,
          )
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

  onlinegoogleMap() {
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
      markers: Set.from(onlineallMarkers),
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  pickUpDropMarker() async {
    onlineallMarkers.add(
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
          await getBytesFromAsset("assets/home/drop.png", 130),
        ),
      ),
    );
    onlineallMarkers.add(
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
                  ),
                ],
              ),
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
          await getBytesFromAsset("assets/home/pickup.png", 60),
        ),
      ),
    );
  }

  goOnlineButton() {
    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              isOnline = !isOnline;
            });
          },
          child: Container(
            height: 110,
            width: 110,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/home/goOnline.png"),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Go\nOnline",
              style: extrabold18White,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  googleMap() {
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

  mapCreated(GoogleMapController controller) async {
    mapController = controller;

    _customInfoWindowController.googleMapController = controller;
    await marker();
    await pickUpDropMarker();
    setState(() {});
  }

  marker() async {
    allMarkers.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: const LatLng(22.566914, 88.357089),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/top - taxi.png", 95),
        ),
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

  currentLocationButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: FloatingActionButton(
        backgroundColor: whiteColor,
        mini: true,
        onPressed: _goCurrentPosition,
        child: const Icon(
          Icons.my_location,
          color: blackColor,
          size: 20,
        ),
      ),
    );
  }

  _goCurrentPosition() async {
    final GoogleMapController controller = mapController!;
    controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
  }

  currentLoationBox() {
    return Padding(
      padding: const EdgeInsets.only(
          top: fixPadding * 4.0,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (Platform.isIOS)
              ? const SizedBox(height: fixPadding * 2.0)
              : const SizedBox(height: 0, width: 0),
          onlineOfflineBox(),
          heightSpace,
          driverAndRideInfo(),
        ],
      ),
    );
  }

  driverAndRideInfo() {
    return Container(
      padding: const EdgeInsets.all(fixPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage("assets/home/User.png"),
              ),
            ),
          ),
          widthSpace,
          width5Space,
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "12 Rides | \$ 350.50",
                style: bold13White,
              ),
              height5Space,
              Text(
                "Today",
                style: semibold12White,
              )
            ],
          )
        ],
      ),
    );
  }

  onlineOfflineBox() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          expansionTileTheme: const ExpansionTileThemeData(
            collapsedIconColor: primaryColor,
            iconColor: primaryColor,
          ),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              menuButton(blackColor),
              widthSpace,
              widthSpace,
              Expanded(
                child: isOnline ? onlineText() : offlineText(),
              )
            ],
          ),
          childrenPadding:
              const EdgeInsets.only(bottom: fixPadding, top: fixPadding / 2),
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isOnline = !isOnline;
                });
              },
              child: Container(
                child: isOnline ? offlineText() : onlineText(),
              ),
            )
          ],
        ),
      ),
    );
  }

  onlineText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
        ),
        widthSpace,
        const Text(
          "You’re Online",
          style: semibold15Black,
        )
      ],
    );
  }

  offlineText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: redColor,
          ),
        ),
        widthSpace,
        const Text(
          "You’re Offline",
          style: semibold15Black,
        )
      ],
    );
  }

  drawer(Size size) {
    return Row(
      children: [
        Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(20.0),
            ),
          ),
          width: size.width * 0.75,
          backgroundColor: whiteColor,
          child: Column(
            children: [
              userInformation(size),
              drawerItemsList(),
            ],
          ),
        ),
        closeButton(size),
      ],
    );
  }

  userInformation(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 5.0, horizontal: fixPadding * 1.5),
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: size.height * 0.09,
            width: size.height * 0.09,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: size.height * 0.085,
                    width: size.height * 0.085,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/home/User.png",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/editProfile').then(
                          (value) => scaffoldKey.currentState?.closeDrawer());
                    },
                    child: Container(
                      height: size.height * 0.038,
                      width: size.height * 0.038,
                      decoration: const BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.border_color_outlined,
                        size: 15,
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          widthSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Samantha Smith",
                  style: bold16White,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "samanthasmith@gmail.com",
                  style: regular14White,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  closeButton(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipPath(
          clipper: CustomMenuClipper(),
          child: Container(
            width: size.width * 0.22,
            height: 130,
            decoration: const BoxDecoration(color: whiteColor),
            padding: const EdgeInsets.only(left: fixPadding / 3),
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                if (scaffoldKey.currentState!.isDrawerOpen) {
                  scaffoldKey.currentState!.closeDrawer();
                }
              },
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: greyColor.withOpacity(0.5),
                      blurRadius: 6,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  drawerItemsList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        physics: const BouncingScrollPhysics(),
        children: [
          drawerItemWidget(Icons.home_rounded, "Home", () {
            scaffoldKey.currentState?.closeDrawer();
          }),
          divider(),
          drawerItemWidget(Icons.drive_eta, "My Rides", () {
            Navigator.pushNamed(context, '/myRides')
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.star, "My Ratings", () {
            Navigator.pushNamed(context, '/myrating')
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.account_balance_wallet_rounded, "Wallet", () {
            Navigator.pushNamed(context, '/wallet')
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.notifications_sharp, "Notification", () {
            Navigator.pushNamed(context, '/notification')
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.gift_fill, "Invite Friends", () {
            Navigator.pushNamed(context, '/inviteFriends')
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.question_circle_fill, "FAQs", () {
            Navigator.pushNamed(context, '/faqs')
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.email, "Contact us", () {
            Navigator.pushNamed(context, '/contactus')
                .then((value) => scaffoldKey.currentState?.closeDrawer());
          }),
          divider(),
          drawerItemWidget(
            Icons.logout,
            "Logout",
            () {
              logoutDialog();
            },
          ),
        ],
      ),
    );
  }

  drawerItemWidget(IconData icon, String title, Function() onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 6))
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: whiteColor,
          size: 16,
        ),
      ),
      minLeadingWidth: 0,
      title: Text(
        title,
        style: bold17Black,
      ),
    );
  }

  logoutDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          insetPadding: const EdgeInsets.all(fixPadding * 2.0),
          contentPadding: const EdgeInsets.all(fixPadding * 2.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.question_circle_fill,
                    color: primaryColor,
                  ),
                  widthSpace,
                  Expanded(
                    child: Text(
                      "Do You Want to Logout...?",
                      style: semibold16Black,
                    ),
                  )
                ],
              ),
              heightSpace,
              heightSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding, horizontal: fixPadding * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: greyShade3),
                        color: whiteColor,
                      ),
                      child: const Text(
                        "Cancel",
                        style: bold16Grey,
                      ),
                    ),
                  ),
                  widthSpace,
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding, horizontal: fixPadding * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: buttonShadow,
                        color: primaryColor,
                      ),
                      child: const Text(
                        "Logout",
                        style: bold16White,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
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

  menuButton(Color color) {
    return InkWell(
      onTap: () {
        scaffoldKey.currentState?.openDrawer();
      },
      child: Icon(
        Icons.notes,
        color: color,
      ),
    );
  }

  onWillpop(context) {
    DateTime now = DateTime.now();
    if (backpressTime == null ||
        now.difference(backpressTime!) >= const Duration(seconds: 2)) {
      backpressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: blackColor,
          content: Text(
            "Press back once again to exit",
            style: bold15White,
          ),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 10, 10, 19);
    path.conicTo(width, height / 2, 5, height - 18, 1.0);
    path.conicTo(0, height - 12, 0, height, 1.4);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
