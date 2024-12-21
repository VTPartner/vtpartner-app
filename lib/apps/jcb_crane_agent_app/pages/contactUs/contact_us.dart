import 'package:flutter/material.dart';

import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/global/global.dart' as glb;

class JcbCraneAgentContactUsScreen extends StatefulWidget {
  const JcbCraneAgentContactUsScreen({super.key});

  @override
  State<JcbCraneAgentContactUsScreen> createState() =>
      _JcbCraneAgentContactUsScreenState();
}

class _JcbCraneAgentContactUsScreenState
    extends State<JcbCraneAgentContactUsScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text(
          "Contact us",
          style: appBarStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          feedBackTitle(),
          heightSpace,
          heightSpace,
          callInfo(),
          heightSpace,
          height5Space,
          mainInfo(),
          heightSpace,
          heightSpace,
          orText(),
          heightSpace,
          heightSpace,
          nameField(),
          heightSpace,
          heightSpace,
          emailField(),
          heightSpace,
          heightSpace,
          messageField(),
        ],
      ),
      bottomNavigationBar: submitButton(context, size),
    );
  }

  submitButton(BuildContext context, Size size) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              var name = nameController.text.toString().trim();
              var email = emailController.text.toString().trim();
              var message = messageController.text.toString().trim();

              if (name.isEmpty || email.isEmpty || message.isEmpty) {
                glb.showSnackBar(context,
                    "All fields are required to help us serve you better. Thank you!");
                return;
              }
              glb.showSnackBar(context,
                  "Thank you for reaching out to us. We will get back to you shortly.");
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
              });
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
                "Submit",
                style: bold18White,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  messageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Message",
          style: semibold15Grey,
        ),
        TextField(
          controller: messageController,
          cursorColor: primaryColor,
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter your message",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGreyColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email Address",
          style: semibold15Grey,
        ),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          cursorColor: primaryColor,
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter your email address",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGreyColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Full Name",
          style: semibold15Grey,
        ),
        TextField(
          controller: nameController,
          keyboardType: TextInputType.name,
          cursorColor: primaryColor,
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter your name",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGreyColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  orText() {
    return const Text(
      "Or send your message",
      style: bold18Black,
    );
  }

  mainInfo() {
    return const Row(
      children: [
        Icon(
          Icons.mail,
          color: primaryColor,
          size: 22,
        ),
        widthSpace,
        Expanded(
          child: Text(
            "support@vtpartner.in",
            style: semibold16Grey,
          ),
        )
      ],
    );
  }

  callInfo() {
    return const Row(
      children: [
        Icon(
          Icons.call,
          color: primaryColor,
          size: 22,
        ),
        widthSpace,
        Expanded(
          child: Text(
            "+91 9665141555",
            style: semibold16Grey,
          ),
        )
      ],
    );
  }

  feedBackTitle() {
    return const Text(
      "Let us know your issue & feedback",
      style: bold18Black,
    );
  }
}
