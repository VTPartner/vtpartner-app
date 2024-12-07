import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:vt_partner/themes/themes.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({super.key});

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  final myRidesList = [
    {
      "image": "assets/editProfile/user.png",
      "name": "Tynisha Obey",
      "price": "\$30.50",
      "time": "Today 01:17 pm",
      "pickAddress": "9 Bailey Drive, Fredericton, NB E3B 5A3",
      "dropAddress": "1655 Island Pkwy, Kamloops, BC V2B 6Y9"
    },
    {
      "image": "assets/editProfile/user.png",
      "name": "Leslie Alexander",
      "price": "\$25.50",
      "time": "Fri 05 Jun, 2020 06:31 am",
      "pickAddress": "38 Whiteshell Avenue, Winnipeg, MB R2C",
      "dropAddress": "225 Belleville St, Victoria, BC V8V 1X1"
    },
    {
      "image": "assets/editProfile/user.png",
      "name": "Esther Howard",
      "price": "\$35.500",
      "time": "Thu 04 Jun, 2020 07:00 am",
      "pickAddress": "6387 Arad Street, Niagara Falls, ON L2G 2Z7",
      "dropAddress": "225 Belleville St, Victoria, BC V8V 1X1"
    }
  ];
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
          "My Rides",
          style: appBarStyle,
        ),
      ),
      body: myRideList(size),
    );
  }

  myRideList(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      itemCount: myRidesList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/rideDetail');
          },
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding, vertical: fixPadding * 1.5),
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: lightGreyColor),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: size.height * 0.08,
                      width: size.height * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            myRidesList[index]['image'].toString(),
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
                            myRidesList[index]['time'].toString(),
                            style: semibold16Black,
                            overflow: TextOverflow.ellipsis,
                          ),
                          heightBox(3.0),
                          Text(
                            myRidesList[index]['name'].toString(),
                            style: semibold14Grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      myRidesList[index]['price'].toString(),
                      style: bold16Primary,
                    )
                  ],
                ),
                heightSpace,
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.radio_button_checked,
                          color: secondaryColor,
                          size: 20,
                        ),
                        widthSpace,
                        widthSpace,
                        Expanded(
                          child: Text(
                            myRidesList[index]['pickAddress'].toString(),
                            style: semibold15Black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: fixPadding),
                          child: DottedBorder(
                            padding: EdgeInsets.zero,
                            strokeWidth: 1.2,
                            dashPattern: const [1, 3],
                            color: blackColor,
                            strokeCap: StrokeCap.round,
                            child: Container(
                              height: 40,
                            ),
                          ),
                        ),
                        widthSpace,
                        Expanded(
                          child: Container(
                            width: double.maxFinite,
                            height: 1,
                            color: lightGreyColor,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: primaryColor,
                          size: 20,
                        ),
                        widthSpace,
                        widthSpace,
                        Expanded(
                          child: Text(
                            myRidesList[index]['dropAddress'].toString(),
                            style: semibold15Black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
