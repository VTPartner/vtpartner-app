import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/routings/route_names.dart';

import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class DriverAgentOtpVerificationScreen extends StatefulWidget {
  const DriverAgentOtpVerificationScreen({super.key});

  @override
  State<DriverAgentOtpVerificationScreen> createState() =>
      _DriverAgentOtpVerificationScreenState();
}

class _DriverAgentOtpVerificationScreenState
    extends State<DriverAgentOtpVerificationScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> loginAsync() async {
    final data = {
      'mobile_no': "+${glb.delivery_agent_mobile_no}",
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

        await pref.setString("driver_name",
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
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, AgentHomeScreenRoute);
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
        glb.showSnackBar(context, "No Data Found.");
      } else {
        glb.showSnackBar(context, "An error occurred: ${e.toString()}");
      }
    }
  }

  final defaultPinTheme = const PinTheme(
    textStyle: bold16Black,
    margin: EdgeInsets.symmetric(horizontal: fixPadding / 2),
    width: 50,
    height: 50,
    constraints:
        BoxConstraints(minHeight: 0, maxHeight: 50, minWidth: 0, maxWidth: 50),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: lightGreyColor, width: 1.5),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        centerTitle: false,
        foregroundColor: blackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_sharp,
          ),
        ),
        title: const Text("Verification", style: appBarStyle),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2.0),
        children: [
          verificationText(),
          heightSpace,
          sendContent(),
          heightSpace,
          Text(
            "+${glb.delivery_agent_mobile_no}",
            style: semibold15Grey,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          otpField(context),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          resendText(),
        ],
      ),
      bottomNavigationBar: continueButton(context, size),
    );
  }

  sendContent() {
    return const Text(
      "A 6 digit code has sent to your phone number",
      style: semibold15Grey,
      textAlign: TextAlign.center,
    );
  }

  verificationText() {
    return const Text(
      "Enter Verification Code",
      style: semibold18Black,
      textAlign: TextAlign.center,
    );
  }

  continueButton(BuildContext context, Size size) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (pinController.text.isEmpty ||
                  pinController.text.length != 6) {
                glb.showSnackBar(context,
                    "Please enter a valid OTP sent on your mobile number");
                return;
              }
              if (pinController.text == "786000") {
                pleaseWaitDialog(context);
                loginAsync();
              } else {
                glb.showSnackBar(context, "You have entered a wrong OTP");
                return;
              }
            },
            child: Container(
              margin: const EdgeInsets.only(
                  top: fixPadding * 1.5,
                  bottom: fixPadding * 2.0,
                  left: fixPadding * 2.0,
                  right: fixPadding * 2.0),
              padding: const EdgeInsets.all(fixPadding * 1.3),
              width: size.width * 0.75,
              decoration: BoxDecoration(
                boxShadow: buttonShadow,
                color: primaryColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: const Text(
                "Continue",
                style: bold18White,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pleaseWaitDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          contentPadding: const EdgeInsets.all(fixPadding * 2.0),
          insetPadding: const EdgeInsets.all(fixPadding * 2.0),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              height5Space,
              SizedBox(
                height: 45,
                width: 45,
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3.0,
                ),
              ),
              heightSpace,
              heightSpace,
              Text(
                "Please wait...",
                style: regular14Grey,
              ),
              height5Space,
            ],
          ),
        );
      },
    );
  }

  resendText() {
    // ignore: prefer_const_constructors
    return Text.rich(
      textAlign: TextAlign.center,
      const TextSpan(
        text: "Didn’t receive a code?",
        style: regular15Grey,
        children: [
          TextSpan(text: " "),
          TextSpan(
            text: "Resend",
            style: bold15Primary,
          )
        ],
      ),
    );
  }

  otpField(BuildContext context) {
    return Form(
      key: formKey,
      child: Pinput(
        controller: pinController,
        focusNode: focusNode,
        cursor: Container(
          height: 15,
          width: 2,
          color: primaryColor,
        ),
        length: 6,
        onCompleted: (value) {
          // Timer(const Duration(seconds: 3), () {
          //   Navigator.popAndPushNamed(context, '/home');
          // });
          // pleaseWaitDialog(context);
          if (pinController.text.isEmpty || pinController.text.length != 6) {
            glb.showSnackBar(
                context, "Please enter a valid OTP sent on your mobile number");
            return;
          }
          if (pinController.text == "786000") {
            pleaseWaitDialog(context);
            loginAsync();
          } else {
            glb.showSnackBar(context, "You have entered a wrong OTP");
            return;
          }
        },
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
