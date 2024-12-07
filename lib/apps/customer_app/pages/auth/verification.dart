import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/global/global.dart' as glb;

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
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
          const Text(
            "Enter Verification Code",
            style: semibold18Black,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          const Text(
            "A 6 digit code has sent to your phone number",
            style: semibold15Grey,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          Text(
            "+${glb.customer_mobile_no}",
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
          backgroundColor: whiteColor,
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
    return const Text.rich(
      TextSpan(
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
      textAlign: TextAlign.center,
    );
  }

  Future<void> loginAsync() async {
    final data = {
      'mobile_no': "+${glb.customer_mobile_no}",
    };

    final pref = await SharedPreferences.getInstance();

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/login', data);
      if (kDebugMode) {
        print(response);
      }

      if (response.containsKey("results")) {
        await pref.setString(
            "customer_id", response["results"][0]["customer_id"].toString());

        await pref.setString("customer_name",
            response["results"][0]["customer_name"].toString());
        await pref.setString(
            "profile_pic", response["results"][0]["profile_pic"].toString());
        await pref.setString(
            "mobile_no", response["results"][0]["mobile_no"].toString());
        await pref.setString(
            "full_address", response["results"][0]["full_address"].toString());
        await pref.setString(
            "email", response["results"][0]["email"].toString());
        await pref.setString(
            "gst_no", response["results"][0]["gst_no"].toString());
        await pref.setString(
            "gst_address", response["results"][0]["gst_address"].toString());

        var customer_name = response["results"][0]["customer_name"].toString();

        if (customer_name.isNotEmpty && customer_name == "NA") {
          await pref.setString("mobile_no", "+${glb.customer_mobile_no}");
          Navigator.pushReplacementNamed(context, NewCustomerDetailsRoute);
        } else {
          await pref.setString("mobile_no", "+${glb.customer_mobile_no}");
          Navigator.pushReplacementNamed(context, CustomerMainScreenRoute);
        }
      } else if (response.containsKey("result")) {
        await pref.setString("mobile_no", "+${glb.customer_mobile_no}");
        await pref.setString(
            "customer_id", response["result"][0]["customer_id"].toString());
        Navigator.pushReplacementNamed(context, NewCustomerDetailsRoute);
      }
    } catch (e) {
      pref.setString("customer_id", "");
      pref.setString("customer_name", "");

      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Data Found.");
      } else {
        glb.showToast("Something went wrong");
        // //glb.showToast("An error occurred: ${e.toString()}");
      }
    }
  }
}
