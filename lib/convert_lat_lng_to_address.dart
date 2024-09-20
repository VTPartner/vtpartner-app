import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class ConvertLatLngToAddress extends StatefulWidget {
  const ConvertLatLngToAddress({super.key});

  @override
  State<ConvertLatLngToAddress> createState() => _ConvertLatLngToAddressState();
}

class _ConvertLatLngToAddressState extends State<ConvertLatLngToAddress> {
  String stAddress = "", stPlaceMark="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(stAddress),
          Text(stPlaceMark),
          GestureDetector(
            onTap: () async {
              List<Location> locations = await locationFromAddress("Gronausestraat 710, Enschede");
              List<Placemark> placemarks = await placemarkFromCoordinates(52.2165157, 6.9437819);
              setState(() {
                stAddress = locations.last.longitude.toString() +" "+locations.last.latitude.toString();
                stPlaceMark = placemarks.reversed.last.country.toString() + " " + placemarks.reversed.last.subLocality.toString()+" - "+placemarks.reversed.last.postalCode.toString();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.green),
                child: Center(
                  child: Text('Convert'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
