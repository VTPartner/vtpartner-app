import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/circular_network_image.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';

class ServiceTypeScreen extends StatefulWidget {
  const ServiceTypeScreen({super.key});

  @override
  State<ServiceTypeScreen> createState() => _ServiceTypeScreenState();
}

class _ServiceTypeScreenState extends State<ServiceTypeScreen> {
  List<DeliveryService> services = [];

  @override
  void initState() {
    super.initState();
    // Initialize the services
    services = [
      DeliveryService(
        name: "Local",
        description:
            "Fast and reliable delivery for goods within your city or nearby areas, ensuring same-day or next-day delivery based on distance.",
        imageUrl:
            "https://img.freepik.com/free-vector/transport-traffic-vehicles-design_24877-49988.jpg?t=st=1725971081~exp=1725974681~hmac=52ecb492606abf9567c52dda76463b826ccb69bdf33cac328c19493ef8af305b&w=1380",
      ),
      DeliveryService(
        name: "OutStation",
        description:
            "Seamless long-distance delivery for goods across cities or states, providing secure and timely delivery for all your intercity needs.",
        imageUrl:
            "https://img.freepik.com/free-vector/delivery-service-truck-isolated_24877-54159.jpg?uid=R27551772&ga=GA1.1.351563377.1719731448&semt=ais_hybrid",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
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
                HeadingText(title: 'Choose Your Preferred Service ?'),
                
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();
                      
                      if (index == 1) {
                        Fluttertoast.showToast(
                            msg: 'Coming Soon', gravity: ToastGravity.BOTTOM);
                        return;
                      }
                      pref.setString("service_type", "local");
                      Navigator.pushNamed(
                          context, PickUpAndDropBookingLocationsRoute);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeadingText(title: service.name),
                                SizedBox(height: 10),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  child: Text(
                                    service.description,
                                    style: nunitoSansStyle.copyWith(
                                        color: Colors.grey, fontSize: 10.0),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 50, // Adjust size as needed
                              height: 50, // Adjust size as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(service.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class DeliveryService {
  final String name;
  final String description;
  final String imageUrl;

  DeliveryService({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}
