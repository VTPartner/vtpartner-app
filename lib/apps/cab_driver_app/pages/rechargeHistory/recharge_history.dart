import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/apps/goods_driver_app/models/rechargeHistoryModel.dart';
import 'package:vt_partner/apps/widgets/column_builder.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class CabDriverRechargeHistoryScreen extends StatefulWidget {
  const CabDriverRechargeHistoryScreen({super.key});

  @override
  State<CabDriverRechargeHistoryScreen> createState() =>
      _CabDriverRechargeHistoryScreenState();
}

class _CabDriverRechargeHistoryScreenState
    extends State<CabDriverRechargeHistoryScreen> {
  String currentBalance = "0";
  List<RechargeHistoryModel> rechargeHistoryModel = [];
  double limitExceededBalance = 0;
  bool isExpired = false;

  Future<void> fetchCurrentBalance() async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");

    final data = {
      'driver_id': goods_driver_id,
    };

    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var address = appInfo.userCurrentLocation?.locationName;
    if (address == null || address.isEmpty) {
      MyApp.restartApp(context);
      // return;
    }

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_goods_driver_current_recharge_details',
          data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      bool hasNegativePoints = false;
      if (response['results'] != null) {
        var ret = response['results'];
        currentBalance = ret[0]['remaining_points'].toString();
        var negativePoints = ret[0]['negative_points'];

        print("negativePoints::$negativePoints");
        if (negativePoints > 0) {
          print("entered negative points");
          currentBalance = negativePoints.toString();
          limitExceededBalance = double.parse(currentBalance);
          hasNegativePoints = true;
          currentBalance = "-$currentBalance";
          setState(() {});
          glb.showSnackBar(context,
              "To continue receiving ride requests, please ensure your account is recharged.\nThank you for your prompt attention.");
        }

        var validTillDateStr = ret[0]['valid_till_date'];
        print("valid_till_date::$validTillDateStr");

// Convert valid_till_date to a DateTime object
        DateTime validTillDate = DateTime.parse(validTillDateStr);

// Get the current date
        DateTime currentDate = DateTime.now();

// Format both dates to "yyyy-MM-dd" to ensure only the date portion is compared
        String formattedValidTillDate =
            DateFormat('yyyy-MM-dd').format(validTillDate);
        String formattedCurrentDate =
            DateFormat('yyyy-MM-dd').format(currentDate);

        print("formattedCurrentDate::$formattedCurrentDate");
        print("formattedValidTillDate::$formattedValidTillDate");

// Parse the formatted dates back to DateTime objects to remove time
        DateTime parsedValidTillDate =
            DateTime.parse("$formattedValidTillDate 00:00:00");
        DateTime parsedCurrentDate =
            DateTime.parse("$formattedCurrentDate 00:00:00");

        print("parsedValidTillDate::$parsedValidTillDate");
        print("parsedCurrentDate::$parsedCurrentDate");

// Check if valid_till_date is before or on the current date
        print("hasNegativePoints::$hasNegativePoints");
        if (parsedValidTillDate.isBefore(parsedCurrentDate) ||
            parsedValidTillDate.isAtSameMomentAs(parsedCurrentDate)) {
          print("Valid till date is valid, no action needed.");
        } else {
          print("Valid till date is in the future. Updating balance to 0.");
          if (hasNegativePoints) {
            currentBalance =
                "-${limitExceededBalance.toString()}"; // Set to negative balance
            isExpired = true;
            glb.showSnackBar(context,
                "Your previous plan has expired. Please recharge promptly to continue receiving ride requests.");
          }
        }

        print("remaining_points::$currentBalance");
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showSnackBar(
            context, "Not Yet Subscribed to any Top-Up Recharge plan.");
      } else {
        //glb.showSnackBar(
        // context,"An error occurred: ${e.toString()}");
      }
    } finally {}
  }

  Future<void> fetchAllRechargesHistory() async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");
    final data = {
      'driver_id': goods_driver_id,
    };

    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var address = appInfo.userCurrentLocation?.locationName;
    if (address == null || address.isEmpty) {
      MyApp.restartApp(context);
      // return;
    }
    setState(() {
      rechargeHistoryModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_goods_driver_recharge_history_details',
          data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> servicesData = response['results'];
        // Map the list of service data into a list of Service objects
        print("servicesData::$servicesData");
        setState(() {
          rechargeHistoryModel = servicesData
              .map((serviceJson) => RechargeHistoryModel.fromJson(serviceJson))
              .toList();

          print("history::${rechargeHistoryModel[0].amount}");
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showSnackBar(context, "No Recharge History Found.");
      } else {
        //glb.showSnackBar(
        // context,"An error occurred: ${e.toString()}");
      }
    } finally {
      // Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllRechargesHistory();
    fetchCurrentBalance();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0.0,
          elevation: 0.0,
          backgroundColor: whiteColor,
          foregroundColor: blackColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_sharp),
          ),
          title: const Text(
            "Recharge History",
            style: appBarStyle,
          ),
        ),
        body: rechargeHistoryModel.isEmpty
            ? emptyContent()
            : Column(
                children: [
                  walletBalance(size),
                  height5Space,
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding, horizontal: fixPadding * 2.0),
                      children: [
                        const Text(
                          "Previous Records",
                          style: bold18Black,
                        ),
                        ColumnBuilder(
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: fixPadding),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 22,
                                        width: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.history),
                                        ),
                                      ),
                                      widthSpace,
                                      widthSpace,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${rechargeHistoryModel[index].paymentID}",
                                              style: semibold16Black,
                                            ),
                                            Text(
                                              "${glb.getDayFromDate(rechargeHistoryModel[index].rechargeDate)} ${rechargeHistoryModel[index].rechargeDate}",
                                              style: regular14Grey,
                                            ),
                                            Text(
                                              "${rechargeHistoryModel[index].points.round()} Points",
                                              style: bold12Primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "₹${rechargeHistoryModel[index].amount.round()}/-",
                                            style: bold16Primary,
                                          ),
                                          rechargeHistoryModel[index]
                                                      .lastRechargeNegativePoints !=
                                                  0.0
                                              ? Text(
                                                  "- ₹${rechargeHistoryModel[index].lastRechargeNegativePoints}/-",
                                                  style: bold16Red,
                                                )
                                              : SizedBox()
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                rechargeHistoryModel.length == index + 1
                                    ? const SizedBox()
                                    : Container(
                                        height: 1,
                                        width: double.maxFinite,
                                        color: lightGreyColor,
                                      )
                              ],
                            );
                          },
                          itemCount: rechargeHistoryModel.length,
                        )
                      ],
                    ),
                  ),
                ],
              ));
  }

  emptyContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: greyShade3,
            size: 30,
          ),
          heightSpace,
          Text(
            "No Recharge History Found",
            style: semibold16Grey,
          )
        ],
      ),
    );
  }

  walletBalance(Size size) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: fixPadding),
        padding: const EdgeInsets.all(fixPadding * 1.5),
        width: size.width * 0.75,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(4, 0),
            ),
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: secondaryColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: whiteColor,
                    size: 22,
                  ),
                ),
                widthSpace,
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recharge",
                        style: bold16Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Gain Points. Drive",
                        style: semibold14Grey,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
            heightSpace,
            const Text(
              "Balance",
              style: semibold14Grey,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "\₹ ${double.parse(currentBalance).round()}",
              style: bold18Black,
            )
          ],
        ),
      ),
    );
  }
}
