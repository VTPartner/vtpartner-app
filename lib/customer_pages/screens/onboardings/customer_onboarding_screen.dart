import 'package:flutter/material.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/widgets/heading_text.dart';

import '../../../themes/themes.dart';
import '../../../utils/app_styles.dart';

class CustomerOnBoardingScreen extends StatefulWidget {
  const CustomerOnBoardingScreen({super.key});

  @override
  State<CustomerOnBoardingScreen> createState() =>
      _CustomerOnBoardingScreenState();
}

class _CustomerOnBoardingScreenState extends State<CustomerOnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/on_boarding.png',
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0),
            child: SizedBox(
              width: width - 100,
              child: Text(
                "Your reliable partner for goods, cabs, vendors.",
                style: nunitoSansStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.backgroundColorDark,
                    fontSize:
                        Theme.of(context).textTheme.displayLarge?.fontSize),
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 20.0, left: 15.0),
            child: SizedBox(
              width: width - 100,
              child: Text(
                "Samaan ho ya ride, sab hum pe chhod do.",
                style: nunitoSansStyle.copyWith(
                    color: Colors.grey[800],
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, CustomerLoginRoute);
                },
                child: Ink(
                  decoration: BoxDecoration(
                      color: ThemeClass.facebookBlue,
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Get Started',
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 16.0, bottom: 0.0),
              child: Text(
                "By continuing, you agree that you have read and accept our ",
                style: nunitoSansStyle.copyWith(
                    color: Colors.grey[800], fontSize: 11.5),
                overflow: TextOverflow.visible,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {},
                  child: Text(
                    "T&Cs",
                    style: nunitoSansStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.grey[900],
                        fontSize: 11.5),
                    overflow: TextOverflow.visible,
                    
                  ),
                ),
                Text(
                  " and ",
                  style: nunitoSansStyle.copyWith(
                      color: Colors.grey[800], fontSize: 11.5),
                  overflow: TextOverflow.visible,
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    "Privacy Policy",
                    style: nunitoSansStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.grey[900],
                        fontSize: 11.5),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
