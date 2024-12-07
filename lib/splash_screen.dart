// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vt_partner/animation/fade_animation.dart';
import 'package:vt_partner/animation/scale_and_revert_animation.dart';
import 'package:vt_partner/animation/slide_bottom_animation.dart';
import 'package:vt_partner/animation/slide_left_animation.dart';

import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/routings/route_names.dart';

import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:shared_preferences/shared_preferences.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  void _animateContainer() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _delaySplash(); // Update the width for the animation
      });
    });
  }

  void _delaySplash() async {
    try {
      final pref = await SharedPreferences.getInstance();
      var first_run = pref?.getString('first_run');
      var customer_id = pref?.getString('customer_id');
      var mobile_no = pref?.getString('mobile_no');
      var openCustomer = pref.getBool('openCustomer');
      var openDriver = pref?.getBool('openDriver');
      // pref.setString("customer_id", "");
      // pref.setString("customer_name", "");
      var customer_name = pref?.getString('customer_name');
      if (customer_id != null &&
          customer_id.isNotEmpty &&
          mobile_no != null &&
          mobile_no.isNotEmpty &&
          customer_name != null &&
          customer_name.isNotEmpty &&
          customer_name != "NA") {
        if (openCustomer != null &&
            openCustomer == true &&
            openDriver != null &&
            openDriver == false)
          Navigator.pushReplacementNamed(context, CustomerMainScreenRoute);
        else if (openCustomer != null &&
            openCustomer == false &&
            openDriver != null &&
            openDriver == true)
          Navigator.pushReplacementNamed(context, AgentHomeScreenRoute);
        else
          Navigator.pushReplacementNamed(context, CustomerMainScreenRoute);
      } else if (customer_id != null &&
          customer_id.isNotEmpty &&
          mobile_no != null &&
          mobile_no.isNotEmpty &&
          customer_name != null &&
          customer_name.isNotEmpty) {
        Navigator.pushReplacementNamed(context, NewCustomerDetailsRoute);
      } else {
        Navigator.pushReplacementNamed(context, OnBoardingRoute);
      }
    } catch (e) {
      print("Error initializing SharedPreferences: $e");
    }
  }


    

  Future<void> _getUserLocationAndAddress() async {
    try {
      Position position = await getUserCurrentLocation();
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoOrdinates(
              position!, context, false);
      
      print("MyLocation::" + humanReadableAddress);
      if (humanReadableAddress.isEmpty) {
        _getUserLocationAndAddress();
      }
    } catch (e) {
      
      print("Error: ${e.toString()}");
      
    }
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error:::" + error.toString());
    });

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }


  @override
  void initState() {
    super.initState();
    glb.initializeEndpoints();
    _getUserLocationAndAddress();
    _animateContainer();

  }

  @override
  Widget build(BuildContext context) {
    double  width = MediaQuery.of(context).size.width; 
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //     Image.asset(
                      //   "assets/icons/fast_delivery.png",
                      //   width: 20,
                      //   height: 20,
                      //   color: Colors.greenAccent[700],
                      // ),
                      // FadeAnimation(
                      //     delay: 3,
                      //     child: Icon(
                      //       Icons.location_on,
                      //     )),
                      // FadeAnimation(
                      //   delay: 2,
                      //   child: Text(
                      //     "VT PARTNER",
                      //     style: nunitoSansStyle.copyWith(
                      //         color: ThemeClass.facebookBlue,
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 46),
                      //   ),
                      // ),
                      SlideFromLeftAnimation(
                        delay: 1,
                        child: Image.asset("assets/images/logo_new.png",width: width -100,)),
                      SlideFromLeftAnimation(
                        delay: 1.5,
                        child: Text(
                          "Samaan ho ya ride, sab hum pe chhod do.",
                          style: nunitoSansStyle.copyWith(
                              color: Colors.grey[800],
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.fontSize),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeAnimation(
                delay: 1.5,
                child: Text(
                  'Copyright © VT Partner Trans Pvt Ltd',
                  textAlign: TextAlign.center,
                  style: nunitoSansStyle.copyWith(
                      color: Colors.grey[800],
                      fontSize: 12,
                      decoration: TextDecoration.none),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
