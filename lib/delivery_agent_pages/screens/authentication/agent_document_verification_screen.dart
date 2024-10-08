import 'package:flutter/material.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/google_drop_down_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

class AgentDocumentVerificationScreen extends StatefulWidget {
  const AgentDocumentVerificationScreen({super.key});

  @override
  State<AgentDocumentVerificationScreen> createState() =>
      _AgentDocumentVerificationScreenState();
}

class _AgentDocumentVerificationScreenState
    extends State<AgentDocumentVerificationScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30.0,
                    color: Colors.grey[900],
                  )),
              SizedBox(
                height: kHeight,
              ),
              Text(
                "Owner Information",
                style: nunitoSansStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.backgroundColorDark,
                    fontSize:
                        Theme.of(context).textTheme.displayMedium?.fontSize),
                overflow: TextOverflow.visible,
              ),
              Text(
                "Your information is kept confidential and used solely for verification and communication purposes",
                style: nunitoSansStyle.copyWith(
                    color: Colors.grey[800],
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                overflow: TextOverflow.visible,
              ),
              SizedBox(
                height: kHeight + 10,
              ),
              GoogleTextFormField(
                  hintText: 'Enter your as per document',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Owner Name *'),
              SizedBox(
                height: kHeight,
              ),
              Row(
                children: [
                  HeadingText(title: 'Upload the required documents'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '*',
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 14.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: kHeight,
              ),
              documentStyle(
                  () {}, Icons.fire_truck_outlined, 'Driving License'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {}, Icons.person_3, 'Aadhar Card [ Owner ]'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(
                  () {}, Icons.tab_unselected_sharp, 'PAN Card [ Owner ]'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {}, Icons.camera, 'Owner Selfie'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              SizedBox(
                height: kHeight + 100,
              ),
            ],
          ),
        ),
      )),
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
                  Navigator.pushNamed(
                      context, AgentVehicleDocumentVerificationRoute);
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
                              'Continue',
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Material documentStyle(Function onTap, IconData iconData, String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    iconData,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      title,
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

