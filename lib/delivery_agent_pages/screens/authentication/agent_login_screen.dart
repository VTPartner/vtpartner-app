import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vt_partner/customer_pages/screens/authentication/customer_login.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/global/global.dart' as glb;

class AgentLoginScreen extends StatefulWidget {
  const AgentLoginScreen({super.key});

  @override
  State<AgentLoginScreen> createState() => _AgentLoginScreenState();
}

class _AgentLoginScreenState extends State<AgentLoginScreen> {
  CountryCode _selectedCountryCode = CountryCode(code: '+91', flag: '🇮🇳');
  final TextEditingController _mobileController = TextEditingController();
  final List<CountryCode> _countryCodes = [
    CountryCode(code: '+91', flag: '🇮🇳'), // India
    // CountryCode(code: '+971', flag: '🇸🇩'), // UAE
  ];
  bool _isButtonVisible = false;
  bool _isErrorVisible = false;
  final FocusNode _focusNode = FocusNode();

  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mobileController.addListener(() {
      setState(() {
        _isButtonVisible = _mobileController.text.isNotEmpty;
        _isErrorVisible = false;
      });
    });

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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                    "Please Enter Phone number for verification",
                    style: nunitoSansStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeClass.backgroundColorDark,
                        fontSize: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.fontSize),
                    overflow: TextOverflow.visible,
                  ),
                  Text(
                    "We'll text a code to verify your phone number",
                    style: nunitoSansStyle.copyWith(
                        color: Colors.grey[800],
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize),
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(
                    height: kHeight,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: ThemeClass.facebookBlue, width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: DropdownButton<CountryCode>(
                          value: _selectedCountryCode,
                          items: _countryCodes.map((CountryCode country) {
                            return DropdownMenuItem<CountryCode>(
                              value: country,
                              child: Row(
                                children: [
                                  Text(country.flag),
                                  const SizedBox(width: 8),
                                  Text(
                                    country.code,
                                    style: robotoStyle.copyWith(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCountryCode = newValue!;
                            });
                          },
                          underline:
                              const SizedBox(), // Remove the default underline
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height:
                              48, // Set the height to match the DropdownButton
                          child: TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Mobile Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  width: 1.0,
                                ),
                              ),
                              filled: true, // Enable filling the background
                              fillColor: Colors
                                  .white, // Set the background color to white
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12, // Padding for the actual text
                              ), // Center the text vertically
                            ),
                            validator: _validateMobileNumber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Note: By proceeding, you consent to get calls, WhatsApp or SMS messages, including by automated means, from VTPartner and its affiliates to the number provided.",
              style: nunitoSansStyle.copyWith(
                  color: Colors.grey[800], fontSize: 11.5),
              overflow: TextOverflow.visible,
            ),
            SizedBox(
              height: 15.0,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  var mobile_no = _mobileController.text.toString().trim();
                  if (mobile_no.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Please enter your mobile number",
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else if (mobile_no.length < 10 || mobile_no.length > 10) {
                    Fluttertoast.showToast(
                      msg: "Please enter valid 10 digits mobile number",
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else {
                    glb.delivery_agent_mobile_no = mobile_no;
                  Navigator.pushNamed(context, AgentOTPRoute);
                  }
                  //Navigator.pushNamed(context, AgentOTPRoute);
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
                              'Get Verification Code',
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
