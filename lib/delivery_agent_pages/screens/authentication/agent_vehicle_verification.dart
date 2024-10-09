import 'package:flutter/material.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/google_drop_down_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

class AgentVehicleDocumentVerification extends StatefulWidget {
  const AgentVehicleDocumentVerification({super.key});

  @override
  State<AgentVehicleDocumentVerification> createState() =>
      _AgentVehicleDocumentVerificationState();
}

class _AgentVehicleDocumentVerificationState
    extends State<AgentVehicleDocumentVerification> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                "Owner Vehicle Information",
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
                  hintText: 'Enter your vehicle number',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Vehicle Number *'),
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
                  () {},
                  Icons.verified,
                  'Registration Certificate (RC)',
                  'Proof of vehicle ownership and registration',
                  width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {}, Icons.verified_user, 'Insurance Certificate',
                  'Valid insurance for the vehicle', width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(
                  () {},
                  Icons.car_crash,
                  'Fitness Certificate',
                  'For commercial vehicles, confirming that the vehicle is fit for operation.',
                  width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(
                  () {},
                  Icons.air_rounded,
                  'Pollution Under Control (PUC) Certificate',
                  'Proof that the vehicle meets emission standards.',
                  width),
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
                  Navigator.pushNamed(context, AgentHomeScreenRoute);
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
                              'Submit',
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

  Material documentStyle(Function onTap, IconData iconData, String title,
      String desc, double width) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: width - 100,
                          child: Text(
                            desc,
                            style: nunitoSansStyle.copyWith(
                                color: Colors.grey, fontSize: 10.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
