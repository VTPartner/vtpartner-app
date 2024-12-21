import 'package:flutter/material.dart';

import 'package:vt_partner/themes/themes.dart';

class HandyManAgentFAQsScreen extends StatefulWidget {
  const HandyManAgentFAQsScreen({super.key});

  @override
  State<HandyManAgentFAQsScreen> createState() =>
      _HandyManAgentFAQsScreenState();
}

class _HandyManAgentFAQsScreenState extends State<HandyManAgentFAQsScreen> {
  final faqList = [
    {
      "title": "Sign in Issue",
      "question": "Issue regarding login, register, verification etc.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Goods Booking",
      "question": "Issue regarding booking a ride.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Payment",
      "question": "Problem related to payment methods.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Map Loading",
      "question": "Map loading issue, route issue, location picker etc.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Report Driver",
      "question": "Report misbehave driver, block driver.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Other Issue",
      "question": "Wrong information provided fake driver etc.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    }
  ];

  @override
  Widget build(BuildContext context) {
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
          "FAQs",
          style: appBarStyle,
        ),
      ),
      body: faqsListContent(),
    );
  }

  faqsListContent() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding),
      itemCount: faqList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                expansionTileTheme: const ExpansionTileThemeData(
                  iconColor: primaryColor,
                  collapsedIconColor: primaryColor,
                  collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
                ),
              ),
              child: ExpansionTile(
                iconColor: primaryColor,
                shape: const RoundedRectangleBorder(),
                childrenPadding: const EdgeInsets.only(bottom: fixPadding),
                tilePadding:
                    const EdgeInsets.symmetric(vertical: fixPadding / 2),
                title: Text(
                  faqList[index]['title'].toString(),
                  style: semibold14Grey,
                ),
                subtitle: Text(
                  faqList[index]['question'].toString(),
                  style: semibold16Black,
                ),
                children: [
                  Text(
                    faqList[index]['answer'].toString(),
                    style: regular14Grey,
                  ),
                ],
              ),
            ),
            faqList.length == index + 1
                ? const SizedBox()
                : Container(
                    height: 1,
                    color: lightGreyColor,
                    width: double.maxFinite,
                  )
          ],
        );
      },
    );
  }
}
