import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/apps/widgets/column_builder.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/all_orders_model.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vt_partner/global/global.dart' as glb;

class GoodsDriverEarningHistory extends StatefulWidget {
  const GoodsDriverEarningHistory({super.key});

  @override
  State<GoodsDriverEarningHistory> createState() =>
      _GoodsDriverEarningHistoryState();
}

class _GoodsDriverEarningHistoryState extends State<GoodsDriverEarningHistory> {
  final transactionList = [
    {
      "image": "assets/wallet/Image1.png",
      "title": "Received for ride",
      "time": "Today, 10:25 am",
      "price": "\$30.50",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image2.png",
      "title": "Received for ride",
      "time": "Wed 17 Jun, 2020 07:39 am",
      "price": "\$20.50",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image3.png",
      "title": "Send to Friend",
      "time": "Mon 29 Jun, 2020 07:40 am",
      "price": "\$10.00",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image4.png",
      "title": "Added to wallet",
      "time": "Tue 23 Jun, 2020 01:17 pm",
      "price": "\$30.50",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image5.png",
      "title": "Send to Bank",
      "time": "Thu 04 Jun, 2020 07:00 am",
      "price": "\$12.50",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image6.png",
      "title": "Received for ride",
      "time": "Mon 01 Jun, 2020 05:05 pm",
      "price": "\$10.50",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image7.png",
      "title": "Received from Friend",
      "time": "Fri 05 Jun, 2020 06:31 am",
      "price": "\$15.00",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image8.png",
      "title": "Added to wallet",
      "time": "Wed 17 Jun, 2020 06:49 am",
      "price": "\$20.50",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image9.png",
      "title": "Received for ride",
      "time": "Mon 08 Jun, 2020 01:55 am",
      "price": "\$30.50",
      "ispaid": false
    },
  ];

  List<double> monthlyEarnings = [];
  double monthlyEarningsTotal = 0;

  Future<void> fetchWholeYearsEarnings() async {
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
      monthlyEarnings = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_whole_year_earnings', data);
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> servicesData = response['results'];
        // Map the list of service data into a list of Service objects
        // print("servicesData::$servicesData");

        setState(() {
          monthlyEarningsTotal = calculateMonthlyEarnings(servicesData);
          print(
              'Total Monthly Earnings: \$${monthlyEarningsTotal.toStringAsFixed(2)}');

          // Map the servicesData to extract only total_earnings as double and update monthlyEarnings
          monthlyEarnings = servicesData
              .map((service) => (service['total_earnings'] as double))
              .toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showSnackBar(context, "No Records Found.");
        Navigator.pop(context);
      } else {
        //glb.showSnackBar(
        // context,"An error occurred: ${e.toString()}");
      }
    } finally {
      // Navigator.pop(context);
    }
  }

  // Extract total earnings and calculate the total
  double calculateMonthlyEarnings(List<dynamic> servicesData) {
    // Map to extract earnings and sum them up
    double totalEarnings = servicesData
        .map((service) => service['total_earnings'] as double)
        .reduce((value, element) => value + element);

    return totalEarnings;
  }

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
    fetchWholeYearsEarnings();
    fetchAllOrders();
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
          "My Earnings",
          style: appBarStyle,
        ),
      ),
      body: Column(
        children: [
          monthlyEarnings.isEmpty
              ? SizedBox()
              : WalletBalanceChart(
                  monthlyEarnings: monthlyEarnings,
                  monthlyEarningsTotal: monthlyEarningsTotal),
          height5Space,
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  vertical: fixPadding, horizontal: fixPadding * 2.0),
              children: [
                const Text(
                  "Earning History",
                  style: bold18Black,
                ),
                ColumnBuilder(
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: fixPadding),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: size.height * 0.07,
                                width: size.height * 0.07,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                      "assets/images/demo_user.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              widthSpace,
                              widthSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allOrdersModel[index].customer_name!,
                                      style: semibold16Black,
                                    ),
                                    Text(
                                      "${glb.getDayFromDate(allOrdersModel[index].booking_date!)} ${allOrdersModel[index].booking_date!}",
                                      style: regular14Grey,
                                    )
                                  ],
                                ),
                              ),
                              Text(
                                "+${double.parse(allOrdersModel[index].total_price!).round()}",
                                style: bold16Primary,
                              )
                            ],
                          ),
                        ),
                        transactionList.length == index + 1
                            ? const SizedBox()
                            : Container(
                                height: 1,
                                width: double.maxFinite,
                                color: lightGreyColor,
                              )
                      ],
                    );
                  },
                  itemCount: allOrdersModel.length,
                ),
              ],
            ),
          ),
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
                        "Earnings",
                        style: bold16Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Default Payment Method",
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
              "Earned till now",
              style: semibold14Grey,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              "\$250.50",
              style: bold18Black,
            )
          ],
        ),
      ),
    );
  }
}

class WalletBalanceChart extends StatelessWidget {
  final List<double> monthlyEarnings;
  final double monthlyEarningsTotal;

  WalletBalanceChart({
    required this.monthlyEarnings,
    required this.monthlyEarningsTotal,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.all(24.0),
        width: size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(4, 0),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                    color: Colors.blue,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Earnings Overview",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Monthly Breakdown",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "₹${monthlyEarningsTotal.round()} /-",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyEarnings.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final monthIndex =
                              value.toInt() - 1; // Convert to zero-based index
                          if (monthIndex < 0 || monthIndex > 11) {
                            return const SizedBox
                                .shrink(); // Return an empty widget for out-of-range values
                          }
                          final months = [
                            "Jan",
                            "Feb",
                            "Mar",
                            "Apr",
                            "May",
                            "Jun",
                            "Jul",
                            "Aug",
                            "Sep",
                            "Oct",
                            "Nov",
                            "Dec"
                          ];
                          return Text(
                            months[monthIndex],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                        reservedSize: 22,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    monthlyEarnings.length,
                    (index) => BarChartGroupData(
                      x: index + 1,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyEarnings[index],
                          color: primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
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
}
