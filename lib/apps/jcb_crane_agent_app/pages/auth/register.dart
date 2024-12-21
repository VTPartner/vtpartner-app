import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';

class JcbCraneAgentRegistrationScreen extends StatefulWidget {
  const JcbCraneAgentRegistrationScreen({super.key});

  @override
  State<JcbCraneAgentRegistrationScreen> createState() =>
      _JcbCraneAgentRegistrationScreenState();
}

class _JcbCraneAgentRegistrationScreenState
    extends State<JcbCraneAgentRegistrationScreen> {
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
          nameField(),
          heightSpace,
          heightSpace,
          emailField(),
          heightSpace,
          heightSpace,
          phoneField()
        ],
      ),
      bottomNavigationBar: continueButton(context, size),
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
              Navigator.pushNamed(context, '/verification');
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

  emailField() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
          style: semibold15Grey,
        ),
        TextField(
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

  nameField() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Full Name",
          style: semibold15Grey,
        ),
        TextField(
          style: bold16Black,
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
