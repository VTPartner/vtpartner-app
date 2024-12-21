import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';

class GoodsDriverEditProfileScreen extends StatefulWidget {
  const GoodsDriverEditProfileScreen({super.key});

  @override
  State<GoodsDriverEditProfileScreen> createState() =>
      _GoodsDriverEditProfileScreenState();
}

class _GoodsDriverEditProfileScreenState
    extends State<GoodsDriverEditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController vehicalNumberController = TextEditingController();

  final carBrandList = [
    "Toyota",
    "Maruti Suzuki",
    "Hyundai",
    "Mahindra",
    "Tata Motors",
  ];

  String? carBrandName;

  final carModelList = [
    "Toyota Innova",
    "Maruti Wagon R",
    "Hyundai Creta",
    "Mahindra Xuv500",
    "Hyundai I10",
    "Renault Kwid",
    "Hyundai I20"
  ];

  String? carModelName;

  @override
  void initState() {
    nameController.text = "Cameron Williamson";
    emailController.text = "cameronwilliamson@gmail.com";
    phoneController.text = "+91 1236457890";
    passwordController.text = "123456789";
    vehicalNumberController.text = "GJ 5 AB 1258";
    setState(() {
      carBrandName = carBrandList[0];
      carModelName = carModelList[0];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text(
          "Edit Profile",
          style: appBarStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          heightSpace,
          heightSpace,
          heightSpace,
          userInformationBox(),
          heightSpace,
          heightSpace,
          heightSpace,
          carInfoBox(),
          heightSpace,
          heightSpace,
          heightSpace,
          documentContentBox(context)
        ],
      ),
      bottomNavigationBar: saveButton(size),
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

  documentContentBox(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: whiteColor,
            border: Border.all(color: lightGreyColor),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heightBox(fixPadding * 2.0),
              govertmentId(context),
              heightSpace,
              heightSpace,
              licenceUploded(),
              heightSpace
            ],
          ),
        ),
        Positioned(
          top: -10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              color: whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: fixPadding),
              child: const Text(
                "Document",
                style: bold18Black,
              ),
            ),
          ),
        )
      ],
    );
  }

  licenceUploded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                "License",
                style: semibold15Grey,
              ),
            ),
            Text(
              "Upload",
              style: bold14Primary,
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: fixPadding),
          child: Row(
            children: [
              Icon(
                Icons.verified_user,
                color: greyShade2,
                size: 20,
              ),
              widthSpace,
              Expanded(
                child: Text(
                  "Not yet uploaded",
                  style: bold16Black,
                ),
              )
            ],
          ),
        ),
        Container(
          height: 1,
          color: lightGreyColor,
          width: double.maxFinite,
        )
      ],
    );
  }

  govertmentId(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Government ID",
          style: semibold15Grey,
        ),
        InkWell(
          onTap: () {
            chnageProfilePhotoSheet(context);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: fixPadding),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: primaryColor,
                  size: 20,
                ),
                widthSpace,
                Expanded(
                  child: Text(
                    "Voted.jpg",
                    style: bold16Black,
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: lightGreyColor,
          width: double.maxFinite,
        )
      ],
    );
  }

  carInfoBox() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: whiteColor,
            border: Border.all(color: lightGreyColor),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heightBox(fixPadding * 2.0),
              carBrandSelection(),
              heightSpace,
              height5Space,
              carModelSelection(),
              heightSpace,
              height5Space,
              vehicalNumberField(),
              heightSpace,
            ],
          ),
        ),
        Positioned(
          top: -10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              color: whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: fixPadding),
              child: const Text(
                "Car Info",
                style: bold18Black,
              ),
            ),
          ),
        )
      ],
    );
  }

  vehicalNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vehicle Number",
          style: semibold15Grey,
        ),
        TextField(
          style: bold16Black,
          controller: vehicalNumberController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter vehical number",
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

  carModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Car Model",
          style: semibold15Grey,
        ),
        DropdownButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: primaryColor,
            ),
            dropdownColor: whiteColor,
            isExpanded: true,
            value: carModelName,
            items: List.generate(
              carModelList.length,
              (index) => DropdownMenuItem(
                value: carModelList[index],
                child: Text(carModelList[index], style: bold16Black),
              ),
            ),
            onChanged: (value) {
              setState(() {
                carModelName = value.toString();
              });
            })
      ],
    );
  }

  carBrandSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Car Brand",
          style: semibold15Grey,
        ),
        DropdownButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: primaryColor,
            ),
            dropdownColor: whiteColor,
            underline: Container(
              height: 1,
              color: lightGreyColor,
              width: double.maxFinite,
            ),
            isExpanded: true,
            value: carBrandName,
            items: List.generate(
              carBrandList.length,
              (index) => DropdownMenuItem(
                value: carBrandList[index],
                child: Text(carBrandList[index], style: bold16Black),
              ),
            ),
            onChanged: (value) {
              setState(() {
                carBrandName = value.toString();
              });
            })
      ],
    );
  }

  userInformationBox() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: whiteColor,
            border: Border.all(color: lightGreyColor),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heightBox(fixPadding * 4.0),
              nameField(),
              heightSpace,
              heightSpace,
              emialAddress(),
              heightSpace,
              heightSpace,
              phoneField(),
              heightSpace,
              heightSpace,
              passwordField(),
              heightSpace,
            ],
          ),
        ),
        profileImage(),
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
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter password",
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

  phoneField() {
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
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter phone number",
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

  emialAddress() {
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
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter email address",
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

  profileImage() {
    return Positioned(
      top: -40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding),
          color: whiteColor,
          child: Stack(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage("assets/editProfile/user.png"),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    chnageProfilePhotoSheet(context);
                  },
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: blackColor.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          )
                        ]),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt,
                      color: primaryColor,
                      size: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
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
}
