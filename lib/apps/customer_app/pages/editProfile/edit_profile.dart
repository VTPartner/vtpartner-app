import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    nameController.text = 'Samantha Smith';
    emailController.text = 'samanthasmith@gmail.com';
    phoneController.text = '+91 1236457890';
    passwordController.text = '123456789';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "Edit Profile",
          style: appBarStyle,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2.0),
        children: [
          userProfileImage(size, context),
          heightSpace,
          heightSpace,
          nameField(),
          heightSpace,
          heightSpace,
          emailField(),
          heightSpace,
          heightSpace,
          phoneNumberField(),
          heightSpace,
          heightSpace,
          passwordField(),
        ],
      ),
      bottomNavigationBar: saveButton(size),
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

  phoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Phone Number",
          style: semibold15Grey,
        ),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          cursorColor: primaryColor,
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter your phone number",
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

  passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: semibold15Grey,
        ),
        TextField(
          obscureText: true,
          controller: passwordController,
          keyboardType: TextInputType.visiblePassword,
          cursorColor: primaryColor,
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter your password",
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

  userProfileImage(Size size, BuildContext context) {
    return Center(
      child: SizedBox(
        height: size.height * 0.125,
        width: size.height * 0.12,
        child: Stack(
          children: [
            Container(
              height: size.height * 0.12,
              width: size.height * 0.12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                image: DecorationImage(
                  image: AssetImage("assets/editProfile/User.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 3,
              child: InkWell(
                onTap: () {
                  chnageProfilePhotoSheet(context);
                },
                child: Container(
                  height: size.height * 0.04,
                  width: size.height * 0.04,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: primaryColor,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  chnageProfilePhotoSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              heightSpace,
              heightSpace,
              const Text(
                "Choose Option",
                style: bold18Black,
              ),
              heightSpace,
              imageChageOption(context, "Use Camera", Icons.camera_alt),
              heightSpace,
              heightSpace,
              imageChageOption(context, "Upload from Gallery", Icons.image),
              heightSpace,
              heightSpace,
              imageChageOption(
                  context, "Remove Photo", CupertinoIcons.delete_solid),
            ],
          ),
        );
      },
    );
  }

  imageChageOption(BuildContext context, String text1, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: greyShade3,
            size: 20,
          ),
          widthSpace,
          widthSpace,
          Expanded(
            child: Text(
              text1,
              style: semibold15Grey,
            ),
          )
        ],
      ),
    );
  }

  saveButton(Size size) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
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
                "Save",
                style: bold18White,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
