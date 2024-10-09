import 'package:flutter/material.dart';
import 'package:vt_partner/widgets/heading_text.dart';

class CabBookingConfirmedScreen extends StatefulWidget {
  const CabBookingConfirmedScreen({super.key});

  @override
  State<CabBookingConfirmedScreen> createState() =>
      _CabBookingConfirmedScreenState();
}

class _CabBookingConfirmedScreenState extends State<CabBookingConfirmedScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : Column(
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
                        HeadingText(title: 'Booking Confirmed'),
                      ],
                    ),
                  ),
                ],
              ));
  }
}
