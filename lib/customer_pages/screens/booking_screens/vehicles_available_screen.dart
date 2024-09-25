import 'package:flutter/material.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

class VehiclesAvailableScreen extends StatefulWidget {
  const VehiclesAvailableScreen({super.key});

  @override
  State<VehiclesAvailableScreen> createState() =>
      _VehiclesAvailableScreenState();
}

class _VehiclesAvailableScreenState extends State<VehiclesAvailableScreen> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
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
                HeadingText(title: 'Available vehicles'),
              ],
            ),
          ),
            SizedBox(
              height: kHeight,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 15, // Change the item count as needed.
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex =
                              index; // Update the selected index on tap.
                        });
                      },
                      child: Ink(
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? ThemeClass.facebookBlue.withOpacity(0.1)
                                : Colors.white, // Highlight the selected item.
                          ),
                          child: Stack(
                            children: [
                              selectedIndex == index
                                  ? Container(
                                      width: 5,
                                      height:
                                          95, // Set to the same height as the column
                                      decoration: BoxDecoration(
                                          color: ThemeClass.facebookBlue,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12.0),
                                              bottomRight:
                                                  Radius.circular(12.0))),
                                    )
                                  : SizedBox(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.0, right: 2.0, bottom: 2.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                            
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: kHeight,
                                            ),
                                            Image.asset(
                                              "assets/images/vtp_partner_truck.png",
                                              width: 80,
                                              height: 80,
                                            ),
                                            SizedBox(
                                              width: kHeight,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    DescriptionText(
                                                        descriptionText:
                                                            'Tata Ace'),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    selectedIndex == index
                                                        ? Icon(
                                                            Icons.info_outline,
                                                            size: 18,
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                ),
                                                SubTitleText(
                                                    subTitle:
                                                        '750 Kg . 3 Mins'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: HeadingText(title: "Rs.2345/-"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: kHeight + 100,
            ),
          ],
        ),
        bottomSheet: Container(
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, BookingReviewDetailsRoute);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage("assets/images/buttton_bg.png"),
                          fit: BoxFit.cover),
                      color: ThemeClass.facebookBlue,
                      borderRadius: BorderRadius.circular(16.0),
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
                                'Proceed with Tata Ace',
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
            ],
          ),
        ));
  
  }
}
