import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:vt_partner/themes/themes.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

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
          "Invite Friends",
          style: appBarStyle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          heightBox(size.height * 0.1),
          inviteFriendInfo(size),
        ],
      ),
      bottomNavigationBar: shareButton(),
    );
  }

  shareButton() {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Container(
        height: 50,
        width: 50,
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
        alignment: Alignment.center,
        child: const Icon(
          Icons.share,
          color: primaryColor,
        ),
      ),
    );
  }

  inviteFriendInfo(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/inviteFriends/gift.png",
          height: size.height * 0.2,
          fit: BoxFit.cover,
        ),
        heightSpace,
        heightSpace,
        const Text(
          "Invite Friends",
          style: bold18Black,
        ),
        heightSpace,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: fixPadding),
          child: Text(
            "When your friend sign up with you referral code, you’ll both get 3.0 coupons",
            style: semibold15Grey,
            textAlign: TextAlign.center,
          ),
        ),
        heightSpace,
        heightSpace,
        DottedBorder(
          padding: EdgeInsets.zero,
          radius: const Radius.circular(5.0),
          dashPattern: const [5],
          color: primaryColor,
          strokeWidth: 1.8,
          borderType: BorderType.RRect,
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding * 2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: const Text(
              "DEG148F5",
              style: semibold16Black,
            ),
          ),
        )
      ],
    );
  }
}
