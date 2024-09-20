import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../routings/route_names.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_styles.dart';

class CustomerOTPVerificationScreen extends StatefulWidget {
  const CustomerOTPVerificationScreen({super.key});

  @override
  State<CustomerOTPVerificationScreen> createState() =>
      _CustomerOTPVerificationScreenState();
}

class _CustomerOTPVerificationScreenState
    extends State<CustomerOTPVerificationScreen> {
  bool _isVerified = false;
  final FocusNode _focusNode = FocusNode();

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
  void dispose() {
    _focusNode
        .dispose(); // Dispose the focus node when the widget is removed from the tree
    super.dispose();
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
                  "Please enter the 5 digit code sent to +91 82386 58110 through SMS",
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
                    Navigator.pushNamed(context, CustomerLoginRoute);
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
                  child: Form(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 58,
                          width: 58,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                                setState(() {
                                  _isVerified = true;
                                });
                              } else {
                                setState(() {
                                  _isVerified = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 1.0,
                                ),
                              ),
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 58,
                          width: 58,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                                setState(() {
                                  _isVerified = true;
                                });
                              } else {
                                setState(() {
                                  _isVerified = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 1.0,
                                ),
                              ),
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 58,
                          width: 58,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                                setState(() {
                                  _isVerified = true;
                                });
                              } else {
                                setState(() {
                                  _isVerified = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 1.0,
                                ),
                              ),
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 58,
                          width: 58,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                                setState(() {
                                  _isVerified = true;
                                });
                              } else {
                                setState(() {
                                  _isVerified = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 1.0,
                                ),
                              ),
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
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
            SizedBox(height: 15.0,),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, NewCustomerDetailsRoute);
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
