import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/google_drop_down_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/global/global.dart' as glb;

class NewCustomerDetailsScreen extends StatefulWidget {
  const NewCustomerDetailsScreen({super.key});

  @override
  State<NewCustomerDetailsScreen> createState() =>
      _NewCustomerDetailsScreenState();
}

class _NewCustomerDetailsScreenState extends State<NewCustomerDetailsScreen> {
  String? _selectedValue;
  bool isLoading = false;
  final List<String> _dropdownItems = [
    'Personal',
    'Business',
    // 'Shifting House',
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
    var customer_mobile_no = pref.getString('customer_mobile_no');

    print("customer_id::$customer_id");
    print("customer_id::$customer_mobile_no");
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

      Fluttertoast.showToast(
        msg: e.toString().contains("No Data Found")
            ? "No Data Found."
            : "An error occurred: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
      );
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
      glb.showToast("Please provide your full name first");
      return;
    }

    if (isValidSpecialCharacters(fullName) == false) {
      glb.showToast(
          "Full name should not contain emojis or special characters.");
      return;
    }

    if (email.isEmpty) {
      glb.showToast("Please provide your valid Email ID");
      return;
    }

    if (email.contains("@") == false) {
      glb.showToast("Please provide your valid Email ID");
      return;
    }

    if (isValidEmail(email) == false) {
      // Email is valid
      glb.showToast(
          "Email should not contain special characters except '@', '.', or '_'.");
      return;
    }

    if (_selectedValue == null) {
      glb.showToast(
          "Please select the purpose for which you'd like to use VT Partner's services.");
      return;
    }

    registerAsync();
  }

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
                "Profile Details",
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
                  hintText: 'Enter Your Full Name',
                  textEditingController: fullNameTextEditingController,
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Full Name *'),
              // SizedBox(
              //   height: kHeight,
              // ),
              // GoogleTextFormField(
              //     hintText: 'Family Name (in some contexts)',
              //     textInputType: TextInputType.text,
              //     textCapitalization: TextCapitalization.words,
              //     labelText: 'Last Name'),
              SizedBox(
                height: kHeight,
              ),
              GoogleTextFormField(
                  hintText: 'Enter valid Email ID',
                  textEditingController: emailTextEditingController,
                  textInputType: TextInputType.emailAddress,
                  labelText: 'Email ID'),
              SizedBox(
                height: kHeight,
              ),
              GoogleDropdownButton(
                hintText: 'Choose one option',
          labelText: 'Using VTPartner For :',
          items: _dropdownItems,
          selectedValue: _selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
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
            isLoading
                ? Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(), // Loading animation
                    ),
                  )
                : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                        validateForm();
                        //Navigator.pushNamed(context, CustomerMainScreenRoute);
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
                              'Register',
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
