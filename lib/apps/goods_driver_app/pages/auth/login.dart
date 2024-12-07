import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class GoodsDriverLoginScreen extends StatefulWidget {
  const GoodsDriverLoginScreen({super.key});

  @override
  State<GoodsDriverLoginScreen> createState() => _GoodsDriverLoginScreenState();
}

class _GoodsDriverLoginScreenState extends State<GoodsDriverLoginScreen> {
  DateTime? backpressTime;
  PhoneController _mobileController = PhoneController(null);
  final FocusNode _focusNode = FocusNode();

  Future<void> _getUserLocationAndAddress() async {
    print("obtain address");
    try {
      Position position = await getUserCurrentLocation();
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoOrdinates(
              position!, context, false);
      print("MyLoginLocation::" + humanReadableAddress);
    } catch (e) {}
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
    _getUserLocationAndAddress();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Dismiss the keyboard when focus is lost
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    FocusScope.of(context).unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        bool backStatus = onWillpop(context);
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image(size),
                  heightSpace,
                  heightSpace,
                  welcomeText(),
                  heightSpace,
                  enterToContinueText(),
                  heightSpace,
                  height5Space,
                  phoneField(context),
                  heightSpace,
                  height5Space,
                  continueButton(size),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  image(Size size) {
    return Image.asset(
      "assets/auth/loginImage.png",
      width: double.maxFinite,
      height: size.height * 0.42,
      fit: BoxFit.fill,
    );
  }

  enterToContinueText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Enter your phone number to continue",
        style: semibold15Grey,
      ),
    );
  }

  welcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Welcome to VT Partner",
        style: bold20Black,
      ),
    );
  }

  continueButton(Size size) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_mobileController.value == null) {
          glb.showSnackBar(context, "Please provide your valid Phone Number");
          return;
        }
        print("_mobileController.value::${_mobileController.value!.nsn}");
        if (_mobileController.value != null &&
            _mobileController.value!.countryCode == "91") {
          if (_mobileController.value!.nsn.length != 10) {
            glb.showSnackBar(context,
                "Phone number should contain valid 10 Digits Phone Number");
            return;
          }
        }
        glb.delivery_agent_mobile_no =
            _mobileController.value!.countryCode.toString() +
                "" +
                _mobileController.value!.nsn.toString();
        ;
        Navigator.pushNamed(context, AgentOTPRoute);
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(fixPadding * 2.0),
          width: size.width * 0.75,
          padding: const EdgeInsets.all(fixPadding * 1.3),
          decoration: BoxDecoration(
            color: primaryColor,
            boxShadow: buttonShadow,
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
          child: const Text(
            "Continue",
            style: bold18White,
          ),
        ),
      ),
    );
  }

  phoneField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: PhoneFormField(
        shouldFormat: false,
        cursorColor: primaryColor,
        defaultCountry: IsoCode.IN,
        decoration: const InputDecoration(
          hintText: "Enter your phone number",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: lightGreyColor,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        validator: (value) {
          if (value != null && value.countryCode == "91") {
            if (_mobileController.value!.nsn.length != 10) {
              return 'Phone number must have 10 digits for India';
            }
          }
          return null;
        },
        onChanged: (PhoneNumber? phoneNumber) {
          // Set the updated phone number to the controller when the value changes
          _mobileController.value = phoneNumber;
        },
        countryCodeStyle: bold15Black,
        style: semibold16Black,
        isCountryChipPersistent: false,
        isCountrySelectionEnabled: true,
        countrySelectorNavigator: const CountrySelectorNavigator.dialog(),
        showFlagInInput: true,
        flagSize: 20,
        enabled: true,
        autofocus: false,
      ),
    );
  }

  onWillpop(context) {
    DateTime now = DateTime.now();
    if (backpressTime == null ||
        now.difference(backpressTime!) >= const Duration(seconds: 2)) {
      backpressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: blackColor,
          content: Text(
            "Press back once again to exit",
            style: bold15White,
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
