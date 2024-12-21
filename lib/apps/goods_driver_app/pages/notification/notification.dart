import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';

class GoodsDriverNotificationScreen extends StatefulWidget {
  const GoodsDriverNotificationScreen({super.key});

  @override
  State<GoodsDriverNotificationScreen> createState() =>
      _GoodsDriverNotificationScreenState();
}

class _GoodsDriverNotificationScreenState
    extends State<GoodsDriverNotificationScreen> {
  final notificationList = [
    {
      "image": "assets/notification/close.png",
      "title": "System",
      "time": "10 min ago",
      "notification": "Ride ID #12354 has been cancelled by user."
    },
    {
      "image": "assets/notification/rate.png",
      "title": "Rating",
      "time": "10 min ago",
      "notification": "5 more reviews and rating for you check it now!"
    },
    {
      "image": "assets/notification/ticket.png",
      "title": "Promotion",
      "time": "10 min ago",
      "notification": "Invite friends - Get 3 Coupons each!"
    },
    {
      "image": "assets/notification/done.png",
      "title": "System",
      "time": "10 min ago",
      "notification": "New ride request for you check it now!"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        elevation: 0.0,
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
          "Notification",
          style: appBarStyle,
        ),
      ),
      body: notificationList.isEmpty
          ? emptyNotificationListContent()
          : notificationListContent(),
    );
  }

  emptyNotificationListContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: greyShade3,
            size: 30,
          ),
          heightSpace,
          Text(
            "No Notification Yet",
            style: semibold16Grey,
          )
        ],
      ),
    );
  }

  notificationListContent() {
    return ListView.builder(
      itemCount: notificationList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          background: Container(
            color: redColor,
          ),
          onDismissed: (direction) {
            setState(() {
              notificationList.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: blackColor,
                behavior: SnackBarBehavior.floating,
                duration: Duration(milliseconds: 1500),
                content: Text(
                  "Removed from notification",
                  style: bold15White,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: greyShade2,
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          notificationList[index]['image'].toString(),
                          height: 22,
                          width: 22,
                        ),
                      ),
                      widthSpace,
                      width5Space,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notificationList[index]['title'].toString(),
                                    style: semibold16Black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  notificationList[index]['time'].toString(),
                                  style: regular12Grey,
                                ),
                              ],
                            ),
                            Text(
                              notificationList[index]['notification']
                                  .toString(),
                              style: regular14Grey,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                notificationList.length == index + 1
                    ? const SizedBox()
                    : Container(
                        height: 1,
                        color: lightGreyColor,
                        width: double.maxFinite,
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}
