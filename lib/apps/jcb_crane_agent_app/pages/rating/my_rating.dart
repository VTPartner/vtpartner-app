import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/all_orders_model.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class JcbCraneAgentRatingScreen extends StatefulWidget {
  const JcbCraneAgentRatingScreen({super.key});

  @override
  State<JcbCraneAgentRatingScreen> createState() =>
      _JcbCraneAgentRatingScreenState();
}

class _JcbCraneAgentRatingScreenState extends State<JcbCraneAgentRatingScreen> {
  bool isLoading = true, noOrdersFound = true;
  List<AllOrdersModel2> allOrdersModel = [];

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
              .map((serviceJson) => AllOrdersModel2.fromJson(serviceJson))
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        titleSpacing: 0.0,
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text("My Ratings", style: appBarStyle),
      ),
      body: ratingListContent(),
    );
  }

  ratingListContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      itemCount: allOrdersModel.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: fixPadding * 2.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allOrdersModel[index].customer_name.toString(),
                              style: semibold16Black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              glb.formatEpochToDateTime(double.parse(
                                  allOrdersModel[index].booking_timing!)),
                              style: regular14Grey,
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              allOrdersModel[index].ratings!,
                              style: bold12White,
                            ),
                            width5Space,
                            const Icon(
                              Icons.star,
                              color: yellowColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  heightSpace,
                  allOrdersModel[index].rating_description != "NA"
                      ? Text(
                          allOrdersModel[index].rating_description!,
                          style: semibold14Grey,
                          textAlign: TextAlign.left,
                        )
                      : SizedBox()
                ],
              ),
            ),
            allOrdersModel.length == index + 1
                ? const SizedBox()
                : Container(
                    height: 1,
                    color: lightGreyColor,
                    width: double.maxFinite,
                  )
          ],
        );
      },
    );
  }
}
