import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int selectedRate = 3;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              physics: const BouncingScrollPhysics(),
              children: [
                driverProfileImage(),
                heightSpace,
                drivername(),
                heightSpace,
                heightSpace,
                rateTexr(),
                heightSpace,
                rating(),
                heightSpace,
                heightSpace,
                complimentField(),
                heightSpace,
                heightSpace,
                submitButton(size),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: backHomeButton(context),
    );
  }

  drivername() {
    return const Text(
      "Cameron Williamson",
      style: semibold17Black,
      textAlign: TextAlign.center,
    );
  }

  rateTexr() {
    return Text(
      "You rated ${selectedRate + 1} star to Cameron",
      style: regular16Grey,
      textAlign: TextAlign.center,
    );
  }

  rating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding / 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedRate = i;
                });
              },
              child: Icon(
                Icons.star,
                color:
                    (selectedRate >= i) ? yellowColor : const Color(0xFFD2D2D2),
                size: 28,
              ),
            ),
          )
      ],
    );
  }

  complimentField() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: lightGreyColor),
      ),
      child: const TextField(
        cursorColor: primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2, vertical: fixPadding * 1.5),
          hintText: "Give a compliment",
          hintStyle: regular14Grey,
        ),
      ),
    );
  }

  submitButton(Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/home');
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
            "Submit",
            style: bold18White,
          ),
        ),
      ),
    );
  }

  backHomeButton(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(
            primaryColor.withOpacity(0.05),
          ),
        ),
        child: const Text(
          "Back to Home",
          style: bold18Primary,
        ),
      ),
    );
  }

  driverProfileImage() {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage("assets/driverDetail/Image.png"),
        ),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: fixPadding / 2),
            decoration: BoxDecoration(
              color: blackColor.withOpacity(0.35),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("4.7", style: bold12White),
                width5Space,
                Icon(
                  Icons.star,
                  size: 16,
                  color: yellowColor,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
