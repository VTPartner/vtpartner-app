import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/customer_pages/screens/main_screens/tab_pages/settings_screen_tab.dart';
import 'package:vt_partner/delivery_agent_pages/helpers/settings_menu_agent.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/heading_text.dart';

class AgentSettingsScreen extends StatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  State<AgentSettingsScreen> createState() => _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends State<AgentSettingsScreen> {
  String? driverName;
  Future<void> getDriverDetails() async {
    final pref = await SharedPreferences.getInstance();

    driverName = pref.getString("driver_name");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getDriverDetails();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        Text(
                          "Account Controls",
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ThemeClass.backgroundColorDark,
                              fontSize: 18.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(
                    height: kHeight,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: kHeight,
                      ),
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: ThemeClass.facebookBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '',
                            style: TextStyle(
                                color: Colors.white, // Text color for initials
                                fontWeight: FontWeight.bold,
                                fontSize: 30.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: kHeight,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Edit",
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ThemeClass.facebookBlue,
                              fontSize: 16.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: kHeight,
                  ),
                  driverName != null
                      ? Text(
                          driverName ?? driverName!,
                    style: nunitoSansStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16.5),
                    overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Colors.grey,
                    indent: 20,
                    endIndent: 20,
                  )
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SettingsMenuItemsAgent(
                          icon: Icons.person_2_rounded,
                          title: 'Switch as Customer',
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              CustomerMainScreenRoute,
                              (Route<dynamic> route) =>
                                  false, // Removes all the routes
                            );
                          }),
                    ),
                   
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SettingsMenuItemsAgent(
                          icon: Icons.edit_document,
                          title: 'Current Live Order',
                          onTap: () {
                            Navigator.pushNamed(context, NewTripDetailsRoute);
                          }),
                    ),
                    //  Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 6.0),
                    //   child: SettingsMenuItemsAgent(
                    //       icon: Icons.payment, title: 'Payments', onTap: () {}),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 6.0),
                    //   child: SettingsMenuItemsAgent(
                    //       icon: Icons.edit_document,
                    //       title: 'Documents',
                    //       onTap: () {}),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SettingsMenuItemsAgent(
                          icon: Icons.history,
                          title: 'Delivery History',
                          onTap: () {}),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 6.0),
                    //   child: SettingsMenuItemsAgent(
                    //       icon: Icons.money, title: 'Earnings', onTap: () {}),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SettingsMenuItemsAgent(
                          icon: Icons.help_outline_outlined,
                          title: 'Support/FAQ',
                          onTap: () {}),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SettingsMenuItemsAgent(
                          icon: Icons.group_add_sharp,
                          title: 'Invite Friends',
                          onTap: () {}),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SettingsMenuItemsAgent(
                          icon: Icons.policy,
                          title: 'Privacy Policy',
                          onTap: () {}),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: SettingsMenuItemsAgent(
                          icon: Icons.logout, title: 'Logout', onTap: () {}),
                    ),
                   
                  ],
                ),
              ),
            )
          ],
        ));
  
  }
}
