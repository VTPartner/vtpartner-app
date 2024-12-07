import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:vt_partner/infoHandler/app_info.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _selectedValue;
  bool isLoading = false;
  final List<String> _dropdownItems = [
    'Personal',
    'Business',
  ];

  TextEditingController fullNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();

  Future<void> registerAsync() async {
    print("registration");

    // Access Provider values before starting async operations to prevent rebuild issues.
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userCurrentLocation?.locationLatitude;
    var longitude = appInfo.userCurrentLocation?.locationLongitude;
    var full_address = appInfo.userCurrentLocation?.locationName;
    var pincode = appInfo.userCurrentLocation?.pinCode;

    setState(() {
      isLoading = true;
    });

    final pref = await SharedPreferences.getInstance();
    var customer_id = pref.getString('customer_id');
    var customer_mobile_no = pref.getString('mobile_no');

    print("customer_id::$customer_id");
    print("customer_mobile_no::$customer_mobile_no");
    print("lat::$latitude");
    print("lng::$longitude");
    print("pincode::$pincode");
    var fullName = fullNameTextEditingController.text.toString().trim();
    var email = emailTextEditingController.text.toString().trim();
    final data = {
      'customer_id': customer_id,
      'full_address': full_address,
      'customer_name': fullName,
      'email': email,
      'purpose': _selectedValue.toString().trim(),
      'pincode': pincode,
      'r_lat': latitude,
      'r_lng': longitude,
    };
    print("data::$data");

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/customer_registration', data);

      if (kDebugMode) {
        print(response);
      }

      await pref.setString("customer_name", fullName);
      await pref.setString("mobile_no", customer_mobile_no.toString());
      await pref.setString("full_address", full_address.toString());
      await pref.setString("email", email);

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacementNamed(context, CustomerMainScreenRoute);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool isValidSpecialCharacters(String txt) {
    // Regular expression to match only letters, numbers, and spaces
    final RegExp regex = RegExp(r'^[a-zA-Z0-9 ]+$');
    return regex.hasMatch(txt);
  }

  bool isValidEmail(String email) {
    // Regular expression to validate email format
    final RegExp regex = RegExp(r'^[a-zA-Z0-9@._]+$');
    return regex.hasMatch(email);
  }

  validateForm() {
    var fullName = fullNameTextEditingController.text.toString().trim();
    var email = emailTextEditingController.text.toString().trim();
    if (fullName.isEmpty) {
      glb.showSnackBar(context, "Please provide your full name first");
      return;
    }

    if (isValidSpecialCharacters(fullName) == false) {
      glb.showSnackBar(context,
          "Full name should not contain emojis or special characters.");
      return;
    }

    if (email.isEmpty) {
      glb.showSnackBar(context, "Please provide your valid Email ID");
      return;
    }

    if (email.contains("@") == false) {
      glb.showSnackBar(context, "Please provide your valid Email ID");
      return;
    }

    if (isValidEmail(email) == false) {
      // Email is valid
      glb.showSnackBar(context,
          "Email should not contain special characters except '@', '.', or '_'.");
      return;
    }

    if (_selectedValue == null) {
      glb.showSnackBar(context,
          "Please select the purpose for which you'd like to use VT Partner's services.");
      return;
    }
    glb.pleaseWaitDialog(context);
    registerAsync();
  }

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
        title: const Text("Register", style: appBarStyle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          nameField(fullNameTextEditingController),
          heightSpace,
          heightSpace,
          emailField(emailTextEditingController),
          heightSpace,
          heightSpace,
          dropdownField(),
          heightSpace,
          heightSpace,
          // phoneField()
        ],
      ),
      bottomNavigationBar: continueButton(context, size),
    );
  }

  dropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Option", // Label for the dropdown
          style: semibold15Grey, // Style for the label
        ),
        DropdownButtonFormField<String>(
          value: _selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
          items: _dropdownItems
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item,
                        style: bold16Black), // Style for the dropdown text
                  ))
              .toList(),
          decoration: const InputDecoration(
            hintText: "Select an option", // Placeholder for the dropdown
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightGreyColor, // Border color when not focused
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor, // Border color when focused
                width: 1,
              ),
            ),
          ),
        ),
      ],
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
              // Navigator.pushNamed(context, CustomerOTPVerificationRoute);
              validateForm();
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
                  borderRadius: BorderRadius.circular(5.0)),
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

  phoneField() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: semibold15Grey,
        ),
        TextField(
          style: bold16Black,
          keyboardType: TextInputType.phone,
          cursorColor: primaryColor,
          decoration: InputDecoration(
            hintText: "Enter your phone number",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightGreyColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  emailField(TextEditingController emailTextEditingController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
          style: semibold15Grey,
        ),
        TextField(
          controller: emailTextEditingController,
          style: bold16Black,
          keyboardType: TextInputType.emailAddress,
          cursorColor: primaryColor,
          decoration: InputDecoration(
            hintText: "Enter your email address",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightGreyColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  nameField(TextEditingController fullNameTextEditingController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Full Name",
          style: semibold15Grey,
        ),
        TextField(
          controller: fullNameTextEditingController,
          style: bold16Black,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          cursorColor: primaryColor,
          decoration: InputDecoration(
            hintText: "Enter your full name",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightGreyColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
