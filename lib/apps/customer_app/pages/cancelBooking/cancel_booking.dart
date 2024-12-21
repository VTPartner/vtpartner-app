import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/push_notifications/get_service_key.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  int selectedRate = 3;
  bool isLoading = false;
  final TextEditingController _complimentController = TextEditingController();
  var ratings_description = 'NA';

  Future<void> asyncCancelBooking() async {
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();

    //booking_details_live_track
    try {
      GetServerKey getServerKey = GetServerKey();
      String accessToken = await getServerKey.getServerKeyToken();
      print("serverKeyToken::$accessToken");
      pref.setString("serverKey", accessToken);

      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/cancel_booking', {
        'booking_id': glb.booking_id,
        'customer_id': glb.customerId,
        'driver_id': glb.driverId,
        'pickup_address': glb.pickupAddress,
        'server_token': accessToken,
      });
      if (kDebugMode) {
        print(response);
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        CustomerMainScreenRoute,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Booking Details Found");

        Navigator.pop(context);
      } else {
        //glb.showToast("An error occurred while fetching booking details");
        // glb.showToast("An error occurred while fetching booking details: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(fixPadding * 2.0),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      driverProfileImage(),
                      heightSpace,
                      drivername(),
                      heightSpace,
                      heightSpace,
                      rateTexr(),
                      heightSpace,
                      heightSpace,
                      complimentField(),
                      heightSpace,
                      heightSpace,
                      submitButton(size),
                    ],
                  ),
                ),
              ],
            ),
      // bottomNavigationBar: backHomeButton(context),
      // bottomNavigationBar: submitButton(size),
    );
  }

  drivername() {
    return Text(
      glb.driverName,
      style: semibold17Black,
      textAlign: TextAlign.center,
    );
  }

  rateTexr() {
    return Text(
      "You are about to cancel the booking which was assigned to ${glb.driverName}",
      style: regular16Grey,
      textAlign: TextAlign.center,
    );
  }

  rating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding / 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedRate = i;
                });
              },
              child: Icon(
                Icons.star,
                color:
                    (selectedRate >= i) ? yellowColor : const Color(0xFFD2D2D2),
                size: 28,
              ),
            ),
          )
      ],
    );
  }

  complimentField() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: lightGreyColor),
      ),
      child: TextField(
        controller: _complimentController,
        cursorColor: primaryColor,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2, vertical: fixPadding * 1.5),
          hintText: "Give us the reason",
          hintStyle: regular14Grey,
        ),
      ),
    );
  }

  submitButton(Size size) {
    return GestureDetector(
      onTap: () {
        asyncCancelBooking();
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(fixPadding * 2.0),
          width: size.width * 0.75,
          padding: const EdgeInsets.all(fixPadding * 1.3),
          decoration: BoxDecoration(
            color: primaryColor,
            boxShadow: buttonShadow,
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
          child: const Text(
            "Submit",
            style: bold18White,
          ),
        ),
      ),
    );
  }

  backHomeButton(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(
            primaryColor.withOpacity(0.05),
          ),
        ),
        child: const Text(
          "Back to Home",
          style: bold18Primary,
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
        image: DecorationImage(
          image: NetworkImage(glb.driverImage),
          // image: AssetImage("assets/driverDetail/Image.png"),
        ),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Visibility(
        visible: false,
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
    );
  }
}
