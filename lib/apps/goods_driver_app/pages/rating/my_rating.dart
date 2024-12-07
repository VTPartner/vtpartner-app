import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';

class MyRatingScreen extends StatefulWidget {
  const MyRatingScreen({super.key});

  @override
  State<MyRatingScreen> createState() => _MyRatingScreenState();
}

class _MyRatingScreenState extends State<MyRatingScreen> {
  final ratingList = [
    {
      "image": "assets/rating/Image1.png",
      "name": "Theresa Webb",
      "time": "Today, 10:25 am",
      "rate": 4.7,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
    {
      "image": "assets/rating/Image2.png",
      "name": "Cody Fisher",
      "time": "Thu 11 Jun, 2020 02:22 am",
      "rate": 4.5,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
    {
      "image": "assets/rating/Image3.png",
      "name": "Jacob Jones",
      "time": "Fri 26 Jun, 2020 10:30 pm",
      "rate": 4.0,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
    {
      "image": "assets/rating/Image4.png",
      "name": "Jenny Wilson",
      "time": "Mon 29 Jun, 2020 07:40 am",
      "rate": 4.7,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
    {
      "image": "assets/rating/Image5.png",
      "name": "Brooklyn Simmons",
      "time": "Fri 26 Jun, 2020 12:30 am",
      "rate": 4.2,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
    {
      "image": "assets/rating/Image6.png",
      "name": "Kristin Watson",
      "time": "Tue 23 Jun, 2020 01:17 pm",
      "rate": 4.5,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
    {
      "image": "assets/rating/Image7.png",
      "name": "Savannah Nguyen",
      "time": "Mon 01 Jun, 2020 05:05 pm",
      "rate": 4.7,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
    {
      "image": "assets/rating/Image8.png",
      "name": "Leslie Alexander",
      "time": "Wed 17 Jun, 2020 07:39 am",
      "rate": 4.2,
      "review":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit amiPharetra in elementum duis justo nulla"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        titleSpacing: 0.0,
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text("My Ratings", style: appBarStyle),
      ),
      body: ratingListContent(),
    );
  }

  ratingListContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      itemCount: ratingList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: fixPadding * 2.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              ratingList[index]['image'].toString(),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      widthSpace,
                      width5Space,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ratingList[index]['name'].toString(),
                              style: semibold16Black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              ratingList[index]['time'].toString(),
                              style: regular14Grey,
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              ratingList[index]['rate'].toString(),
                              style: bold12White,
                            ),
                            width5Space,
                            const Icon(
                              Icons.star,
                              color: yellowColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  heightSpace,
                  Text(
                    ratingList[index]['review'].toString(),
                    style: semibold14Grey,
                  )
                ],
              ),
            ),
            ratingList.length == index + 1
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
