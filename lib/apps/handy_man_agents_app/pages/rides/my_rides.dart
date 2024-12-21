import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/all_orders_model.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/routings/route_names.dart';

import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class HandyManAgentRideScreen extends StatefulWidget {
  const HandyManAgentRideScreen({super.key});

  @override
  State<HandyManAgentRideScreen> createState() =>
      _HandyManAgentRideScreenState();
}

class _HandyManAgentRideScreenState extends State<HandyManAgentRideScreen> {
  bool isLoading = true, noOrdersFound = true;
  List<AllOrdersModel> allOrdersModel = [];

  Future<void> fetchAllOrders() async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");
    final data = {
      'driver_id': goods_driver_id,
    };

    setState(() {
      isLoading = true;
      allOrdersModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_all_orders', data);
      if (kDebugMode) {
        print(response);
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
    fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text(
          "My Rides",
          style: appBarStyle,
        ),
      ),
      body: myRideList(size),
    );
  }

  myRideList(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      itemCount: allOrdersModel.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, GoodsDriverRideDetailsRoute);
          },
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding, vertical: fixPadding * 1.5),
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: lightGreyColor),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: size.height * 0.08,
                      width: size.height * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/demo_user.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    widthSpace,
                    width5Space,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            glb.formatEpochToDateTime(double.parse(
                                allOrdersModel[index].booking_timing!)),
                            style: semibold14Black,
                            overflow: TextOverflow.ellipsis,
                          ),
                          heightBox(3.0),
                          Text(
                            "${allOrdersModel[index].customer_name!}",
                            style: semibold14Grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${double.parse(allOrdersModel[index].total_price!).round()}/-",
                      style: bold16Primary,
                    )
                  ],
                ),
                heightSpace,
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.radio_button_checked,
                          color: secondaryColor,
                          size: 20,
                        ),
                        widthSpace,
                        widthSpace,
                        Expanded(
                          child: Text(
                            "${allOrdersModel[index].pickup_address!}",
                            style: semibold12Black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: fixPadding),
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
                        const Icon(
                          Icons.location_on,
                          color: primaryColor,
                          size: 20,
                        ),
                        widthSpace,
                        widthSpace,
                        Expanded(
                          child: Text(
                            "${allOrdersModel[index].drop_address!}",
                            style: semibold12Black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
