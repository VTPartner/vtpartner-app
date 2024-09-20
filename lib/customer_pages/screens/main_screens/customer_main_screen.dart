import 'package:flutter/material.dart';

import 'tab_pages/home_screen_tab.dart';
import 'tab_pages/rewards_screen_tab.dart';
import 'tab_pages/rides_screen_tab.dart';
import 'tab_pages/settings_screen_tab.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(length: 4, vsync: this);
  }

  double searchLocationContainerHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: const [
            HomeScreenTabPage(),
            RidesScreenTabPage(),
            RewardsScreenTabPage(),
            SettingsScreenTabPage()
          ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time_rounded), label: "Rides"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined), label: "Rewards"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
