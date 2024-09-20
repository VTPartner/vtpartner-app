import 'package:flutter/material.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/body_text1.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/dotted_vertical_divider.dart';
import 'package:vt_partner/widgets/heading_text.dart';

class VehiclesAvailableScreen extends StatefulWidget {
  const VehiclesAvailableScreen({super.key});

  @override
  State<VehiclesAvailableScreen> createState() =>
      _VehiclesAvailableScreenState();
}

class _VehiclesAvailableScreenState extends State<VehiclesAvailableScreen> {
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.0,
                      ),
                      Stack(
                        children: [
                        
                          Row(
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/icons/green_dot.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                  DottedVerticalDivider(
                                    height: 44,
                                    width: 1,
                                    color: Colors.grey,
                                    dotRadius: 1,
                                    spacing: 5,
                                  ),
                                  Image.asset(
                                    "assets/icons/red_dot.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pickup",
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.green[900],
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.fontSize),
                                    overflow: TextOverflow.visible,
                                  ),
                                  DescriptionText(
                                      descriptionText:
                                          "Shaheed Maniyar. 8296565587"),
                                  SizedBox(
                                    width: width - 80,
                                    child: BodyText1(
                                        text:
                                            "Plot No 83, Gat 765 Industrial Area phase"),
                                  ),
                                  SizedBox(
                                    height: kHeight,
                                  ),
                                  Text(
                                    "Destination",
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.red,
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.fontSize),
                                    overflow: TextOverflow.visible,
                                  ),
                                  DescriptionText(
                                      descriptionText:
                                          "Arun Patil - 7654343376"),
                                  SizedBox(
                                    width: width - 80,
                                    child: BodyText1(
                                        text:
                                            "Q68R+PJ Ranjangaon, Ashtavinayak Mahamarg, Malthan Rd, Ranjangaon, Maharashtra 412209"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
