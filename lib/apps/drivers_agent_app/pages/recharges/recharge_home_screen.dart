import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/apps/goods_driver_app/models/allRechargeModel.dart';
import 'package:vt_partner/apps/widgets/column_builder.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class DriverAgentRechargeHomeScreen extends StatefulWidget {
  const DriverAgentRechargeHomeScreen({super.key});

  @override
  State<DriverAgentRechargeHomeScreen> createState() =>
      _DriverAgentRechargeHomeScreenState();
}

class _DriverAgentRechargeHomeScreenState
    extends State<DriverAgentRechargeHomeScreen> {
  List<AllRechargesModel> allRechargesModel = [];
  int selectedIndex = 0;
  String currentBalance = "0";
  String topUpID = "0";
  String lastValidityDate = "0";
  Razorpay? _razorpay;
  bool hasNegativePoints = false;
  bool isExpired = false;

  Future<void> fetchAllRecharges() async {
    final data = {
      'category_id': "1",
    };

    final pref = await SharedPreferences.getInstance();

    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var address = appInfo.userCurrentLocation?.locationName;
    if (address == null || address.isEmpty) {
      MyApp.restartApp(context);
      // return;
    }
    setState(() {
      allRechargesModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_goods_driver_recharge_list', data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> servicesData = response['results'];
        // Map the list of service data into a list of Service objects
        setState(() {
          allRechargesModel = servicesData
              .map((serviceJson) => AllRechargesModel.fromJson(serviceJson))
              .toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showSnackBar(context, "No Recharges Found.");
      } else {
        //glb.showSnackBar(
        // context,"An error occurred: ${e.toString()}");
      }
    } finally {}
  }

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
      if (response['results'] != null) {
        var ret = response['results'];
        currentBalance = ret[0]['remaining_points'].toString();
        topUpID = ret[0]['topup_id'].toString();
        // Parse the valid_till_date
        lastValidityDate = ret[0]['valid_till_date'].toString();
        double limitExceededBalance = 0;
        var negativePoints = ret[0]['negative_points'];
        if (negativePoints > 0) {
          currentBalance = negativePoints.toString();
          limitExceededBalance = double.parse(currentBalance);
          previous_negative_points =
              double.parse(currentBalance).round().toDouble();
          currentBalance = "-$currentBalance";
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

  double previous_negative_points = 0;

  Future<void> saveRechargeDetails(String paymentID) async {
    final pref = await SharedPreferences.getInstance();
    var goods_driver_id = pref.getString("goods_driver_id");

    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var address = appInfo.userCurrentLocation?.locationName;
    if (address == null || address.isEmpty) {
      MyApp.restartApp(context);
      // return;
    }

    var allottedPoints = allRechargesModel[selectedIndex].points;
    int validDays = int.parse(allRechargesModel[selectedIndex].validDays);
    DateTime currentDate = DateTime.now(); // Get the current date

    DateTime calculatedDate =
        currentDate.add(Duration(days: validDays)); // Add validDays

    // Optional: Format the date as 'yyyy-MM-dd'
    String formattedDate = DateFormat('yyyy-MM-dd').format(calculatedDate);

    print("Current Date: ${DateFormat('yyyy-MM-dd').format(currentDate)}");
    print("Calculated Date: $formattedDate");

    final data = {
      'driver_id': goods_driver_id,
      "recharge_id": allRechargesModel[selectedIndex].rechargeId,
      "topup_id": topUpID,
      "last_validity_date": lastValidityDate,
      "amount": allRechargesModel[selectedIndex].amount,
      "allotted_points": allottedPoints,
      "valid_till_date": formattedDate,
      "payment_method": "RazorPay",
      "payment_id": paymentID,
      "previous_negative_points": previous_negative_points,
    };

    print("Payment Details Data::$data");

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/new_goods_driver_recharge', data);
      if (kDebugMode) {
        print(response);
      }
      Navigator.pop(context);
      Navigator.pop(context);
      // Navigator.pushNamed(context, GoodsDriverRechargeHomeRoute);
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   AgentHomeScreenRoute,
      //   (Route<dynamic> route) => false,
      // );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showSnackBar(context, "No Recharges Found.");
      } else {
        //glb.showSnackBar(
        // context,"An error occurred: ${e.toString()}");
      }
    } finally {
      Navigator.pop(context); // to remove
      Navigator.pop(context); // to remove
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllRecharges();
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
          "Recharge Plans",
          style: appBarStyle,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          walletBalance(size),
          height5Space,
          const Padding(
            padding: EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding * 2.0),
            child: Text(
              "Plans",
              style: bold18Black,
              textAlign: TextAlign.left,
            ),
          ),
          height5Space,
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  vertical: fixPadding, horizontal: fixPadding * 2.0),
              children: [
                ColumnBuilder(
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        double absoluteBalance = currentBalance.startsWith('-')
                            ? double.parse(currentBalance.substring(1))
                            : double.parse(currentBalance);
                        double points =
                            allRechargesModel[index].points.toDouble();

                        if (absoluteBalance > points) {
                          glb.showSnackBar(context,
                              "Please select a pack that covers your negative balance.");
                        } else if (double.parse(currentBalance) <= 0) {
                          showPaymentOptionsModel(context, size, index);
                        } else {
                          glb.showSnackBar(context,
                              "Multiple top-up recharges are not allowed.");
                        }
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: fixPadding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/notification/ticket.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                widthSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        " ₹ ${allRechargesModel[index].amount} /-",
                                        style: bold16Primary,
                                      ),
                                      Text(
                                        "${allRechargesModel[index].description}",
                                        style: regular12Grey,
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 2.0),
                                      child: Icon(
                                        Icons.timer_outlined,
                                        color: greyColor,
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      "${allRechargesModel[index].validDays} Days",
                                      style: semibold14Black,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          allRechargesModel.length == index + 1
                              ? const SizedBox()
                              : Container(
                                  height: 1,
                                  width: double.maxFinite,
                                  color: lightGreyColor,
                                )
                        ],
                      ),
                    );
                  },
                  itemCount: allRechargesModel.length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showPaymentOptionsModel(BuildContext context, Size size, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
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
              SafeArea(
                child: Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              rechargeDetailList(index)
            ],
          ),
        );
      },
    );
  }

  rechargeDetailList(int index) {
    return ListView(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Plan Information",
              style: bold18Black,
            ),
            heightSpace,
            Row(
              children: [
                otherItemWidget(
                    "Plan Price", "\₹ ${allRechargesModel[index].amount}"),
                otherItemWidget(
                    "Validity", "${allRechargesModel[index].validDays} Days")
              ],
            ),
            heightSpace,
            heightSpace,
            heightSpace,
            payNowButtonWidget(index)
          ],
        )
      ],
    );
  }

  payNowButtonWidget(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 2.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                glb.pleaseWaitDialog(context);
                showRazorPayOption(context, index);
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
                  "Pay Now",
                  style: bold18White,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  showRazorPayOption(BuildContext context, int index) {
    setState(() {
      selectedIndex = index;
    });
    _razorpay = Razorpay();
    Razorpay razorpay = Razorpay();
    var options = {
      'key': glb.razorpay_key,
      'amount': '${allRechargesModel[index].amount.round()}',
      'name': 'VT Partner Trans Pvt Ltd',
      'description': 'Order Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '', 'email': 'test@razorpay.com'},
      'theme': {'color': '#0042D9'},
      'external': {
        'wallets': ['paytm']
      }
    };
    // var options = {
    //   'amount': 10000,
    //   'currency': 'INR',
    //   'prefill': {
    //     'contact': '9877597717',
    //     'email': 'pshibu567@gmail.com'
    //   },
    //   'theme': {'color': '#0CA72F'},
    //   'send_sms_hash': true,
    //   'retry': {'enabled': false, 'max_count': 4},
    //   'key': 'rzp_test_5sHeuuremkiApj',
    //   'order_id': 'order_N0fmkHxFIp7wQh',
    //   'disable_redesign_v15': false,
    //   'experiments.upi_turbo': true,
    //   'ep':
    //       'https://api-web-turbo-upi.ext.dev.razorpay.in/test/checkout.html?branch=feat/turbo/tpv'
    // };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    // * PaymentFailureResponse contains three values:
    // * 1. Error Code
    // * 2. Error Description
    // * 3. Metadata
    // *
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    // * Payment Success Response contains three values:
    // * 1. Order ID
    // * 2. Payment ID
    // * 3. Signature
    // *
    showAlertDialog(
        context, "Payment Successful", "Payment ID: ${response.paymentId}");
    //TODO:do async here and send the driver to recharge history screen
    /**
     * 1. Add Record to Recharge History Table with Payment ID.
     * 2. Allot Points to the driver with valid_days from recharge date.
     * 3. Deduct points if there are any negative points from previous records.
     */

    saveRechargeDetails(response.paymentId!);

    //assets/icons/payment_done.png
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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

  walletBalance(Size size) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: fixPadding),
        padding: const EdgeInsets.all(fixPadding * 1.5),
        width: size.width * 0.85,
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
                        "Top Up Recharge",
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
              "\₹ $currentBalance",
              style: bold18Black,
            )
          ],
        ),
      ),
    );
  }
}
