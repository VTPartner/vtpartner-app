import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/all_guide_lines_model.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/models/all_services_model.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'package:vt_partner/widgets/swipe_button.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:vt_partner/push_notifications/get_service_key.dart';

class BookingReviewScreen extends StatefulWidget {
  const BookingReviewScreen({super.key});

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  ScrollController _scrollController = ScrollController();
  GlobalKey _fareDetailsKey = GlobalKey();
  GlobalKey _rulesDetailsKey = GlobalKey();
  bool _isHighlighted = false;
  bool _isHighlightedRules = false;
  bool isLoading = false;
  double totalPrice = 0.0;
  int selectedIndex = 0;
  List<AllGuideLinesModal> allGuidesModel = [];

  setPriceDetails() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString("booking_id", "");
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var total_price = appInfo.activeBookingDetail?.totalPrice;
    var base_price = appInfo.activeBookingDetail?.basePrice;
    if (total_price! <= base_price!) {
      totalPrice = base_price;
    } else {
      totalPrice = total_price;
    }
  }

  Future<void> fetchAllGuideLines() async {
    setState(() {
      isLoading = true;
      allGuidesModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_all_guide_lines', {});
      if (kDebugMode) {
        // print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> guideLineData = response['results'];
        print("guideLineData::$guideLineData");
        // Map the list of service data into a list of Service objects
        setState(() {
          allGuidesModel = guideLineData
              .map(
                  (guideLineJson) => AllGuideLinesModal.fromJson(guideLineJson))
              .toList();
        });

        print("allGuidesModel length::${allGuidesModel.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Guidelines Found.");
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
    // TODO: implement initState
    super.initState();
    setPriceDetails();
    fetchAllGuideLines();
  }

  Future<void> saveBookingDetailsAsync() async {
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();
    var customer_id = pref.getString("customer_id");
    var pickup_city_id = pref.getString("pickup_city_id");
    if (customer_id == null) {
      glb.showToast("Please Login Again your session has expiried");
      pref.setString("customer_id", "");
      return;
    }
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var driver_id = appInfo.activeBookingDetail?.driverID;
    if (driver_id == null) {
      glb.showToast("Please navigate back and select the vehicle");
      return;
    }

    var pickup_lat = appInfo.userPickupLocation?.locationLatitude;
    var pickup_lng = appInfo.userPickupLocation?.locationLongitude;
    var pickup_address = appInfo.userPickupLocation?.locationName;
    var destination_lat = appInfo.userDropOfLocation?.locationLatitude;
    var destination_lng = appInfo.userDropOfLocation?.locationLongitude;
    var destination_address = appInfo.userDropOfLocation?.locationName;
    var distance = appInfo.activeBookingDetail?.estimatedTotalDistance;
    var time = appInfo.activeBookingDetail?.estimatedTotalTime;
    var total_price = appInfo.activeBookingDetail?.totalPrice;
    var base_price = appInfo.activeBookingDetail?.basePrice;
    var goods_type_id = appInfo.goodsTypesDetail?.goodsTypeID;

    var sender_name = appInfo.senderContactDetail?.contactName;
    var sender_number = appInfo.senderContactDetail?.contactNumber;

    var receiver_name = appInfo.receiverContactDetail?.contactName;
    var receiver_number = appInfo.receiverContactDetail?.contactNumber;

    if (sender_number == null || receiver_number == null) {
      glb.showToast("Please check your sender and receiver contact details");
      return;
    }
    if (goods_type_id == null) {
      goods_type_id = 1;
    }

    if (total_price! < base_price!) {
      total_price = base_price;
    }

    GetServerKey getServerKey = GetServerKey();
    String accessToken = await getServerKey.getServerKeyToken();
    print("serverKeyToken::$accessToken");
    if (accessToken.isEmpty) {
      glb.showToast("Please retry again to book");
      return;
    }

    final data = {
      "customer_id": customer_id,
      "driver_id": driver_id,
      "pickup_lat": pickup_lat,
      "pickup_lng": pickup_lng,
      "destination_lat": destination_lat,
      "destination_lng": destination_lng,
      "distance": distance,
      "time": time,
      "total_price": total_price,
      "base_price": base_price,
      "gst_amount": 0,
      "igst_amount": 0,
      "goods_type_id": goods_type_id,
      "payment_method": "NA",
      "city_id": pickup_city_id,
      "sender_name": sender_name,
      "sender_number": sender_number,
      "receiver_name": receiver_name,
      "receiver_number": receiver_number,
      "pickup_address": pickup_address,
      "drop_address": destination_address,
      "server_access_token": accessToken
    };

    print("boking_data:$data");

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/new_goods_delivery_booking', data);

      if (kDebugMode) {
        print(response);
      }
      if (response.containsKey("result")) {
        pref.setString(
            "booking_id", response["result"][0]["booking_id"].toString());
        pref.setString("totalAmount", total_price.toString());
        Navigator.pushNamed(context, BookingSearchDriverRoute);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      //glb.showToast("An error occurred: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Function to scroll to the fare details container and highlight it
  void _scrollAndHighlightFareDetails() {
    final RenderBox renderBox =
        _fareDetailsKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero).dy;

    _scrollController.animateTo(
      position + _scrollController.offset,
      duration: Duration(milliseconds: 600),
      curve: Curves.ease,
    );

    // Highlight the container temporarily
    setState(() {
      _isHighlighted = true;
    });

    // Remove the highlight after a short duration
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isHighlighted = false;
      });
    });
  }

  void _scrollAndHighlightRulesDetails() {
    final RenderBox renderBox =
        _rulesDetailsKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero).dy;

    _scrollController.animateTo(
      position + _scrollController.offset,
      duration: Duration(milliseconds: 600),
      curve: Curves.ease,
    );

    // Highlight the container temporarily
    setState(() {
      _isHighlightedRules = true;
    });

    // Remove the highlight after a short duration
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isHighlightedRules = false;
      });
    });
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5.0),
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
                              HeadingText(title: 'Booking Review'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              // image: DecorationImage(
                              //   image: AssetImage(
                              //       "assets/images/vt_partner_white_bg.jpeg"),
                              //   fit: BoxFit.cover,
                              // ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      Provider.of<AppInfo>(context)
                                                  .activeBookingDetail !=
                                              null
                                          ? Provider.of<AppInfo>(context)
                                              .activeBookingDetail!
                                              .vehicleImage!
                                          : "assets/images/vtp_partner_truck.png",
                                      width: 60,
                                      height: 60,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Provider.of<AppInfo>(context)
                                                      .activeBookingDetail !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .activeBookingDetail!
                                                  .vehicleName!
                                              : "Vehicle name",
                                          style: nunitoSansStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14.0),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Check Address Details',
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeClass.facebookBlue,
                                          fontSize: 10.0),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  gradient: LinearGradient(colors: [
                                    const Color.fromARGB(255, 24, 251, 58),
                                    Colors.white,
                                  ])),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          'Free ',
                                          style: nunitoSansStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12.0),
                                        ),
                                        Text(
                                                '30 mins ',
                                          style: nunitoSansStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 14.0),
                                        ),
                                        Text(
                                          'of unloading time included. ',
                                          style: nunitoSansStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        _scrollAndHighlightRulesDetails();
                                      },
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                        Visibility(
                          visible: false,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Text(
                                  "Offers and Discounts",
                                  style: nunitoSansStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 12.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, CouponsRoute);
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/icons/offers.png",
                                                color: Colors.green,
                                                width: 20,
                                                height: 20,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text(
                                                  "Apply Coupons",
                                                  style:
                                                      nunitoSansStyle.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                          fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/background.JPG'),
                                      fit: BoxFit.cover,
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  16.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  16.0)),
                                                  color: Colors.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'You will receive',
                                                      style: nunitoSansStyle
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: ThemeClass
                                                                  .backgroundColorDark,
                                                              fontSize: 10.0),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .blur_circular_rounded,
                                                          color:
                                                              Colors.amber[700],
                                                          size: 15,
                                                        ),
                                                        Text(
                                                          '44 Coins on this order',
                                                          style: nunitoSansStyle
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: ThemeClass
                                                                      .facebookBlue,
                                                                  fontSize:
                                                                      12.0),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Fare Summary",
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      key: _fareDetailsKey, // Attach the GlobalKey here
                      decoration: BoxDecoration(
                        color: Colors.white, // Keep the background color white
                        boxShadow: _isHighlighted
                            ? [
                                BoxShadow(
                                  color: ThemeClass.facebookBlue
                                      .withOpacity(0.7), // Shadow color
                                  spreadRadius: 2, // Increase size
                                  blurRadius: 5, // Softness of the shadow
                                  offset:
                                      Offset(0, 2), // Position of the shadow
                                ),
                              ]
                            : [], // No shadow when not highlighted
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Trip Fare (exclusive Toll)",
                                            style: nunitoSansStyle.copyWith(
                                                fontSize: 12.0),
                                          ),
                                          Text(
                                            "If amount is less then base fare then you have to pay base fare. ₹${Provider.of<AppInfo>(context).activeBookingDetail!.basePrice!}",
                                  style:
                                      nunitoSansStyle.copyWith(
                                                fontSize: 8.0),
                                          ),
                                        ],
                                ),
                                Text(
                                        "₹ ${totalPrice}",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.black, fontSize: 12.0),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey.withOpacity(0.5),
                              thickness: 0.2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Net Fare",
                                  style:
                                      nunitoSansStyle.copyWith(fontSize: 12.0),
                                ),
                                Text(
                                        "₹ ${totalPrice}",
                                        style: nunitoSansStyle.copyWith(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey.withOpacity(0.5),
                                    thickness: 0.2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "SGST",
                                        style: nunitoSansStyle.copyWith(
                                            fontSize: 12.0),
                                      ),
                                      Text(
                                        "₹ 0.0",
                                        style: nunitoSansStyle.copyWith(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey.withOpacity(0.5),
                                    thickness: 0.2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "CGST",
                                        style: nunitoSansStyle.copyWith(
                                            fontSize: 12.0),
                                      ),
                                      Text(
                                        "₹ 0.0",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                            
                            Divider(
                              color: Colors.grey.withOpacity(0.5),
                              thickness: 0.2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Amount Payable (rounded)",
                                  style: nunitoSansStyle.copyWith(
                                      fontSize: 12.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                        "₹ ${totalPrice.round()}",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Goods Type",
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shape_line_sharp,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                          Provider.of<AppInfo>(context)
                                                      .goodsTypesDetail !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .goodsTypesDetail!
                                                  .goodsTypeName!
                                              : "Building / Construction",
                                    style: nunitoSansStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 12.0),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, GoodsTypeRoute);
                              },
                              child: Text(
                                "Change",
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeClass.facebookBlue,
                                    fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Read guidelines before booking",
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0),
                    ),
                  ),
                ],
              ),
            ),
SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  key: _rulesDetailsKey,
                  decoration: BoxDecoration(
                    color: Colors.white, // Keep the background color white
                    boxShadow: _isHighlightedRules
                        ? [
                            BoxShadow(
                              color: ThemeClass.facebookBlue
                                  .withOpacity(0.7), // Shadow color
                              spreadRadius: 2, // Increase size
                              blurRadius: 5, // Softness of the shadow
                              offset: Offset(0, 2), // Position of the shadow
                            ),
                          ]
                        : [], // No shadow when not highlighted
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  
                  height: height / 4,
                  child: ListView.builder(
                            itemCount: allGuidesModel.length,
                      itemBuilder: (context, index) {
                              bool isSelected = index == selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 2.0, left: 4.0, right: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.grey,
                                    size: 6,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: SizedBox(
                                      width: width - 70,
                                      child: Text(
                                              allGuidesModel[index]
                                                  .guideLineDsc,
                                        style: nunitoSansStyle.copyWith(
                                            fontSize: 11.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      
                      }),
                ),
              ),
                  ),
                    
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
              ),
            )
          ],
        ),
        bottomSheet: isLoading
            ? SizedBox()
            : Container(
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                          // Visibility(
                          //   visible: false,
                          //   child: Row(
                          //     children: [
                          //       Container(
                          //         decoration: BoxDecoration(
                          //             color: Colors.white,
                          //             border: Border.all(
                          //                 width: 0.5, color: Colors.grey),
                          //             borderRadius: BorderRadius.circular(4.0)),
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(4.0),
                          //           child: Image.asset(
                          //             "assets/icons/cash.png",
                          //             width: 25,
                          //             height: 25,
                          //           ),
                          //         ),
                          //       ),
                          //       SizedBox(
                          //         width: kHeight,
                          //       ),
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Text(
                          //             "Choose Payment Method",
                          //             style: nunitoSansStyle.copyWith(
                          //                 color: Colors.black, fontSize: 12.0),
                          //           ),
                          //           SizedBox(
                          //             height: 4,
                          //           ),
                          //           Text(
                          //             "Cash",
                          //             style: nunitoSansStyle.copyWith(
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Colors.black,
                          //                 fontSize: 14.0),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payments",
                                style: nunitoSansStyle.copyWith(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Post Delivery",
                                style: nunitoSansStyle.copyWith(
                                    color: Colors.black, fontSize: 12.0),
                              ),
                            ],
                          ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                                "Rs.${totalPrice.round()}/-",
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        InkWell(
                          onTap: () {
                            //Should scroll and highlight fare details Container
                            _scrollAndHighlightFareDetails();
                          },
                          child: Text(
                            "View Breakdown",
                            style: nunitoSansStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ThemeClass.facebookBlue,
                                fontSize: 10.0),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              /* Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    //Send to Booking Confirmation Screen
                    // Navigator.pushNamed(context, BookingReviewDetailsRoute);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/buttton_bg.png"),
                          fit: BoxFit.fill),
                      color: ThemeClass.facebookBlue,
                      borderRadius: BorderRadius.circular(12.0),
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
                                'Book Tata Ace',
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
            */
              SwipeToBookButton(
                      title:
                          '   Swipe to book ${Provider.of<AppInfo>(context).activeBookingDetail != null ? Provider.of<AppInfo>(context).activeBookingDetail!.vehicleName! : "Vehicle name"}'
                              .toUpperCase(),
                onDragEnd: () {
                  
                        saveBookingDetailsAsync();
                        //Navigator.pushNamed(context, BookingSearchDriverRoute);
                },
                
              )
            ],
          ),
        ));
  
  
  }

  double _dragPosition = 0.0;

  void _resetDragPosition() {
    setState(() {
      _dragPosition = 0.0; // Reset the drag position
    });
  }
}
