
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:vt_partner/assistants/request_assistance.dart';

import '../../../routings/route_names.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_styles.dart';
import 'package:vt_partner/global/global.dart' as glb;

class AgentOtpVerificationScreen extends StatefulWidget {
  const AgentOtpVerificationScreen({super.key});

  @override
  State<AgentOtpVerificationScreen> createState() =>
      _AgentOtpVerificationScreenState();
}

class _AgentOtpVerificationScreenState
    extends State<AgentOtpVerificationScreen> {
  bool _isVerified = false;
  final FocusNode _focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  TextEditingController otpTextController = TextEditingController();

  @override
  void dispose() {
    _focusNode
        .dispose(); // Dispose the focus node when the widget is removed from the tree
    otpTextController.dispose();
    super.dispose();
  }

  Future<void> loginAsync() async {
    final data = {
      'mobile_no': "+91${glb.delivery_agent_mobile_no}",
    };

    final pref = await SharedPreferences.getInstance();

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_login', data);
      if (kDebugMode) {
        print(response);
      }

      if (response.containsKey("results")) {
        await pref.setString("goods_driver_id",
            response["results"][0]["goods_driver_id"].toString());

        await pref.setString("goods_driver_name",
            response["results"][0]["driver_first_name"].toString());
        await pref.setString(
            "profile_pic", response["results"][0]["profile_pic"].toString());
        await pref.setString(
            "mobile_no", response["results"][0]["mobile_no"].toString());
        await pref.setString(
            "full_address", response["results"][0]["full_address"].toString());

        var goods_driver_name =
            response["results"][0]["driver_first_name"].toString();

        if (goods_driver_name.isNotEmpty && goods_driver_name == "NA") {
          Navigator.pushReplacementNamed(
              context, AgentDocumentVerificationRoute);
        } else {
          Navigator.pushReplacementNamed(context, CustomerMainScreenRoute);
        }
      } else if (response.containsKey("result")) {
        await pref.setString("goods_driver_id",
            response["result"][0]["goods_driver_id"].toString());
        await pref.setString(
            "goods_driver_mobno", glb.delivery_agent_mobile_no);
        Navigator.pushReplacementNamed(context, AgentDocumentVerificationRoute);
      }
    } catch (e) {
      pref.setString("goods_driver_id", "");
      pref.setString("goods_driver_name", "");

      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        Fluttertoast.showToast(
          msg: "No Data Found.",
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: "An error occurred: ${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }


  @override
  void initState() {
    super.initState();
    // Add a listener to the focus node to handle the keyboard visibility
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Dismiss the keyboard when focus is lost
        FocusScope.of(context).unfocus();
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
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
                  "Verify Phone Number",
                  style: nunitoSansStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeClass.backgroundColorDark,
                      fontSize:
                          Theme.of(context).textTheme.displayMedium?.fontSize),
                  overflow: TextOverflow.visible,
                ),
                Text(
                  "Please enter the 5 digit code sent to +91${glb.delivery_agent_mobile_no} 58110 through SMS",
                  style: nunitoSansStyle.copyWith(
                      color: Colors.grey[800],
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium?.fontSize),
                  overflow: TextOverflow.visible,
                ),
                SizedBox(
                  height: kHeight,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AgentLoginRoute);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Edit your phone number ?",
                      style: nunitoSansStyle.copyWith(
                        color: ThemeClass.facebookBlue,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize,
                        decoration: TextDecoration.underline,
                        decorationColor: ThemeClass
                            .facebookBlue, // Set the underline color to match the text color
                      ),
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
                SizedBox(
                  height: kHeight,
                ),
                Padding(
                  padding: const EdgeInsets.all(26.0),
                  child: PinFieldAutoFill(
                    controller: otpTextController,
                    codeLength: 6,
                    onCodeChanged: (code) {
                      if (code!.length == 6 && code == "786000") {
                        //_verifyOtp(code);
                        loginAsync();
                      } else if (code!.length == 6) {
                        Fluttertoast.showToast(
                          msg: "Invalid OTP",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    },
                    onCodeSubmitted: (code) {
                      //_verifyOtp(code);
                      if (code!.length == 6 && code == "786000") {
                        //_verifyOtp(code);
                        loginAsync();
                      } else {
                        Fluttertoast.showToast(
                          msg: "Invalid OTP",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Haven't got the confirmation code yet? ",
                  style: nunitoSansStyle.copyWith(
                      color: Colors.grey[800], fontSize: 11.5),
                  overflow: TextOverflow.visible,
                ),
                Visibility(
                  visible: false,
                  child: Text(
                    " 00:59",
                    style: nunitoSansStyle.copyWith(
                        color: Colors.grey[800], fontSize: 11.5),
                    overflow: TextOverflow.visible,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, CustomerMainScreenRoute);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Resend",
                      style: nunitoSansStyle.copyWith(
                        color: ThemeClass.facebookBlue,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize,
                        decoration: TextDecoration.underline,
                        decorationColor: ThemeClass
                            .facebookBlue, // Set the underline color to match the text color
                      ),
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  var otp = otpTextController.text.toString().trim();
                  if (otp.isEmpty || otp.length < 6) {
                    Fluttertoast.showToast(
                        msg: "Please enter the full otp code first");
                  } else {
                    loginAsync();
                  }
                  // Navigator.pushNamed(context, AgentDocumentVerificationRoute);
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
                              'Verify',
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
}

