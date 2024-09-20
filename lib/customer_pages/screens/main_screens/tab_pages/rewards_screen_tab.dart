import 'package:flutter/material.dart';
import 'package:vt_partner/widgets/main_heading_text.dart';

class RewardsScreenTabPage extends StatefulWidget {
  const RewardsScreenTabPage({super.key});

  @override
  State<RewardsScreenTabPage> createState() => _RewardsScreenTabPageState();
}

class _RewardsScreenTabPageState extends State<RewardsScreenTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              title: MainHeadingText(title: 'Rewards'),
            ),
          ),
          SliverToBoxAdapter()
        ],
      ),
    );
  }
}
