import 'package:flutter/material.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/circular_network_image.dart';
import 'package:vt_partner/widgets/global_filled_button.dart';
import 'package:vt_partner/widgets/global_outlines_button.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/main_heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

class SettingsScreenTabPage extends StatefulWidget {
  const SettingsScreenTabPage({super.key});

  @override
  State<SettingsScreenTabPage> createState() => _SettingsScreenTabPageState();
}

class _SettingsScreenTabPageState extends State<SettingsScreenTabPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ThemeClass.backgroundColorLightPink,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: false,
        pinned: true, // Keeps the app bar pinned at the top
        expandedHeight: 60.0, // Adjust height as needed
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(left: 16.0, bottom: 8.0),
          title: MainHeadingText(title: 'Settings'),
        ),
      ),
          SliverToBoxAdapter(
            child: Column(
              children: [
              
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      SizedBox(
                        height: kHeight - 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 5.0, right: 16.0, left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: ThemeClass
                                          .facebookBlue, // Your chosen background color
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'SM', // Replace with your initials
                                        style: TextStyle(
                                          color: Colors.white, // Text color
                                          fontSize:
                                              20, // Adjust font size as needed
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Shaheed Maniyar',
                                        style: robotoStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                ThemeClass.backgroundColorDark),
                                      ),
                                      Text(
                                        'shahidmaniyar888@gmail.com',
                                        style: robotoStyle.copyWith(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                            width: width - 200,
                            child: GlobalFilledButton(
                                onTap: () {}, label: "Add GST Details")),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Note: Please provide your GST details if you are using our service for business purposes to receive exclusive offers.',
                          textAlign: TextAlign.start,
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 10.0),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: kHeight,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 12.0, right: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 40,
                                decoration: const BoxDecoration(
                                    color: ThemeClass.facebookBlue,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(16.0),
                                        bottomRight: Radius.circular(16.0))),
                              ),
                              SizedBox(
                                width: kHeight,
                              ),
                              Text(
                                "Accounts",
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18.0),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        SettingsMenuItems(
                            icon: Icons.manage_accounts_outlined,
                            title: 'Account Settings',
                            onTap: () {}),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.1,
                          indent: 70,
                          endIndent: 20,
                        ),
                        SettingsMenuItems(
                            icon: Icons.bookmark_outline,
                            title: 'Saved Addresses',
                            onTap: () {}),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.1,
                          indent: 70,
                          endIndent: 20,
                        ),
                        SettingsMenuWithIconItems(
                            icon: Icons.contact_page_outlined,
                            title: "Refer your friends",
                            onTap: () {},
                            buttonIcon: Icons.share,
                            buttonText: "Invite"),
                        SizedBox(
                          height: kHeight,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 12.0, right: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 40,
                                decoration: const BoxDecoration(
                                    color: ThemeClass.facebookBlue,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(16.0),
                                        bottomRight: Radius.circular(16.0))),
                              ),
                              SizedBox(
                                width: kHeight,
                              ),
                              Text(
                                "Assistance",
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18.0),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        SettingsMenuItems(
                            icon: Icons.info_outline_rounded,
                            title: 'About Us',
                            onTap: () {}),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.1,
                          indent: 70,
                          endIndent: 20,
                        ),
                        SettingsMenuItems(
                            icon: Icons.help_outline_sharp,
                            title: 'Help & Support',
                            onTap: () {}),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.1,
                          indent: 70,
                          endIndent: 20,
                        ),
                        SettingsMenuItems(
                            icon: Icons.article_outlined,
                            title: 'Terms and Conditions',
                            onTap: () {}),
                        // Divider(
                        //   color: Colors.grey,
                        //   thickness: 0.1,
                        //   indent: 70,
                        //   endIndent: 20,
                        // ),
                        // SettingsMenuItems(
                        //     icon: Icons.fire_truck_outlined,
                        //     title: 'Register as a Goo',
                        //     onTap: () {
                        //       Navigator.pushNamed(
                        //           context, AgentLoginRoute);
                        //     }),
                        SizedBox(
                          height: kHeight,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 12.0, right: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 40,
                                decoration: const BoxDecoration(
                                    color: ThemeClass.facebookBlue,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(16.0),
                                        bottomRight: Radius.circular(16.0))),
                              ),
                              SizedBox(
                                width: kHeight,
                              ),
                              Text(
                                "More",
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18.0),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        SettingsMenuItems(
                            icon: Icons.manage_accounts_outlined,
                            title: 'Account Settings',
                            onTap: () {}),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.1,
                          indent: 70,
                          endIndent: 20,
                        ),
                        SettingsMenuItems(
                            icon: Icons.bookmark_outline,
                            title: 'Saved Addresses',
                            onTap: () {}),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.1,
                          indent: 70,
                          endIndent: 20,
                        ),
                        SettingsMenuWithIconItems(
                            icon: Icons.contact_page_outlined,
                            title: "Refer your friends",
                            onTap: () {},
                            buttonIcon: Icons.share,
                            buttonText: "Invite"),
                        SizedBox(
                          height: kHeight,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12.0),
                      child: Ink(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(
                                              0.09), // Your chosen background color
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                            child: Icon(
                                          Icons.logout,
                                          color: Colors.red,
                                          size: 20,
                                        )),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.0,
                                    ),
                                    Text(
                                      "Log Out",
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 14.0),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: kHeight,
                ),
              ],
            ),
      
          )
        ],
      ),
    );
  }
}

class SettingsMenuItems extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const SettingsMenuItems({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeClass.facebookBlue
                          .withOpacity(0.09), // Your chosen background color
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Icon(
                      icon,
                      size: 20,
                    )),
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                HeadingText(title: title)
              ],
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}

class SettingsMenuWithIconItems extends StatelessWidget {
  final IconData icon;
  final IconData buttonIcon;
  final String title;
  final String buttonText;
  final VoidCallback onTap;
  const SettingsMenuWithIconItems({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.buttonIcon,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeClass.facebookBlue
                          .withOpacity(0.09), // Your chosen background color
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Icon(
                      icon,
                      size: 20,
                    )),
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                HeadingText(title: title)
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  color: ThemeClass.facebookBlue
                      .withOpacity(0.09), // Your chosen background color
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Row(
                  children: [
                    Icon(
                      buttonIcon,
                      size: 14,
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Text(
                      buttonText,
                      style: nunitoSansStyle.copyWith(
                        color: ThemeClass.facebookBlue,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
