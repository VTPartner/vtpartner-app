import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'package:vt_partner/widgets/swipe_button.dart';

class BookingReviewScreen extends StatefulWidget {
  const BookingReviewScreen({super.key});

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {

  ScrollController _scrollController = ScrollController();
  GlobalKey _fareDetailsKey = GlobalKey();
  GlobalKey _rulesDetailsKey = GlobalKey();
  bool _isHighlighted = false;
  bool _isHighlightedRules = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Function to scroll to the fare details container and highlight it
  void _scrollAndHighlightFareDetails() {
    final RenderBox renderBox =
        _fareDetailsKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero).dy;

    _scrollController.animateTo(
      position + _scrollController.offset,
      duration: Duration(milliseconds: 600),
      curve: Curves.ease,
    );

    // Highlight the container temporarily
    setState(() {
      _isHighlighted = true;
    });

    // Remove the highlight after a short duration
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isHighlighted = false;
      });
    });
  }

  void _scrollAndHighlightRulesDetails() {
    final RenderBox renderBox =
        _rulesDetailsKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero).dy;

    _scrollController.animateTo(
      position + _scrollController.offset,
      duration: Duration(milliseconds: 600),
      curve: Curves.ease,
    );

    // Highlight the container temporarily
    setState(() {
      _isHighlightedRules = true;
    });

    // Remove the highlight after a short duration
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isHighlightedRules = false;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
      return  Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
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
                        HeadingText(title: 'Booking Review'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/images/vt_partner_white_bg.jpeg"),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/vtp_partner_truck.png",
                                width: 60,
                                height: 60,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tata Ace',
                                    style: nunitoSansStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14.0),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Check Address Details',
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeClass.facebookBlue,
                                          fontSize: 10.0),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  gradient: LinearGradient(colors: [
                                    const Color.fromARGB(255, 24, 251, 58),
                                    Colors.white,
                                  ])),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          'Free ',
                                          style: nunitoSansStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12.0),
                                        ),
                                        Text(
                                          '70 mins ',
                                          style: nunitoSansStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 14.0),
                                        ),
                                        Text(
                                          'of unloading time included. ',
                                          style: nunitoSansStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        _scrollAndHighlightRulesDetails();
                                      },
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Offers and Discounts",
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, CouponsRoute);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/icons/offers.png",
                                    color: Colors.green,
                                    width: 20,
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      "Apply Coupons",
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12.0),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.black,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/background.JPG'),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0),
                                          bottomRight: Radius.circular(16.0)),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'You will receive',
                                          style: nunitoSansStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeClass
                                                  .backgroundColorDark,
                                              fontSize: 10.0),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.blur_circular_rounded,
                                              color: Colors.amber[700],
                                              size: 15,
                                            ),
                                            Text(
                                              '44 Coins on this order',
                                              style: nunitoSansStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      ThemeClass.facebookBlue,
                                                  fontSize: 12.0),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Fare Summary",
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      key: _fareDetailsKey, // Attach the GlobalKey here
                      decoration: BoxDecoration(
                        color: Colors.white, // Keep the background color white
                        boxShadow: _isHighlighted
                            ? [
                                BoxShadow(
                                  color: ThemeClass.facebookBlue
                                      .withOpacity(0.7), // Shadow color
                                  spreadRadius: 2, // Increase size
                                  blurRadius: 5, // Softness of the shadow
                                  offset:
                                      Offset(0, 2), // Position of the shadow
                                ),
                              ]
                            : [], // No shadow when not highlighted
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Trip Fare (incl Toll)",
                                  style:
                                      nunitoSansStyle.copyWith(fontSize: 12.0),
                                ),
                                Text(
                                  "₹ 2193.00",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.black, fontSize: 12.0),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey.withOpacity(0.5),
                              thickness: 0.2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Net Fare",
                                  style:
                                      nunitoSansStyle.copyWith(fontSize: 12.0),
                                ),
                                Text(
                                  "₹ 2194",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey.withOpacity(0.5),
                              thickness: 0.2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Amount Payable (rounded)",
                                  style: nunitoSansStyle.copyWith(
                                      fontSize: 12.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "₹ 2194",
                                  style: nunitoSansStyle.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Goods Type",
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shape_line_sharp,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    "Building / Construction .JG",
                                    style: nunitoSansStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 12.0),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, GoodsTypeRoute);
                              },
                              child: Text(
                                "Change",
                                style: nunitoSansStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeClass.facebookBlue,
                                    fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Read guidelines before booking",
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12.0),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  key: _rulesDetailsKey,
                  decoration: BoxDecoration(
                    color: Colors.white, // Keep the background color white
                    boxShadow: _isHighlightedRules
                        ? [
                            BoxShadow(
                              color: ThemeClass.facebookBlue
                                  .withOpacity(0.7), // Shadow color
                              spreadRadius: 2, // Increase size
                              blurRadius: 5, // Softness of the shadow
                              offset: Offset(0, 2), // Position of the shadow
                            ),
                          ]
                        : [], // No shadow when not highlighted
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  
                  height: height / 4,
                  child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 2.0, left: 4.0, right: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.grey,
                                    size: 6,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: SizedBox(
                                      width: width - 70,
                                      child: Text(
                                        "Fare doesn't include labour charges for loading & unloading.",
                                        style: nunitoSansStyle.copyWith(
                                            fontSize: 11.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      
                      }),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
              ),
            )
          ],
        ),
        bottomSheet: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(width: 0.5, color: Colors.grey),
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              "assets/icons/cash.png",
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: kHeight,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Choose Payment Method",
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.black, fontSize: 12.0),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "Cash",
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Rs.2378/-",
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        InkWell(
                          onTap: () {
                            //Should scroll and highlight fare details Container
                            _scrollAndHighlightFareDetails();
                          },
                          child: Text(
                            "View Breakdown",
                            style: nunitoSansStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ThemeClass.facebookBlue,
                                fontSize: 10.0),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              /* Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    //Send to Booking Confirmation Screen
                    // Navigator.pushNamed(context, BookingReviewDetailsRoute);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/buttton_bg.png"),
                          fit: BoxFit.fill),
                      color: ThemeClass.facebookBlue,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Book Tata Ace',
                                style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.fontSize,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            */
              SwipeToBookButton(
                title: 'Swipe to Book Tata Ace',
                onDragEnd: () {
                  Navigator.pushNamed(context, BookingSearchDriverRoute);
                },
                
              )
            ],
          ),
        ));
  
  }

  double _dragPosition = 0.0;

  void _resetDragPosition() {
    setState(() {
      _dragPosition = 0.0; // Reset the drag position
    });
  }
}
