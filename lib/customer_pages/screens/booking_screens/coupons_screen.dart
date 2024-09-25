import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/description_text.dart';
import 'package:vt_partner/widgets/global_filled_button.dart';
import 'package:vt_partner/widgets/global_outlines_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                HeadingText(title: 'Coupons & Offers'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/orders_bg.jpeg"),
                      fit: BoxFit.cover,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(
                height: kHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: width - 150,
                    child: GoogleTextFormField(
                        hintText: 'Enter coupon code',
                        textInputType: TextInputType.text,
                        labelText: 'Enter coupon code'),
                  ),
                  GlobalOutlinedButton(onTap: () {}, label: 'Apply')
                ],
              ),
              SizedBox(
                height: kHeight,
              ),
              Container(
                color: Colors.grey[300],
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DescriptionText(descriptionText: 'More Offers')),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
              child: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey,
                thickness: 0.1,
              );
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "15 % Off",
                            style: nunitoSansStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 12.0),
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                          Text(
                            "Flat Rs. 15% Off!",
                            style: nunitoSansStyle.copyWith(
                                color: Colors.grey, fontSize: 10.0),
                          ),
                          Text(
                            "Get flat Rs. 15 Off on your 1st 2-wheeler order.",
                            style: nunitoSansStyle.copyWith(
                                color: Colors.grey, fontSize: 10.0),
                          ),
                          Text(
                            "Valid till: October 13 2024",
                            style: nunitoSansStyle.copyWith(
                                color: Colors.grey, fontSize: 10.0),
                          ),
                        ],
                      ),
                    ),
                    GlobalFilledButton(onTap: () {}, label: 'Apply')
                  ],
                )),
              );
            },
            itemCount: 5,
          ))
        ],
      ),
    );
  }
}
