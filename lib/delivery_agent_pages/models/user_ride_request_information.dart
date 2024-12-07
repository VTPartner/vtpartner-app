import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformationModel {
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  String? receiverName;
  String? receiverNumber;
  String? senderName;
  String? senderNumber;
  String? customerName;
  String? customerId;
  String? pickupAddress;
  String? dropAddress;
  String? totalDistance;
  String? totalTime;
  double? totalPrice;
  String? bookingId;
  String? customerNumber;
  String? otp;
  double? pickupLat;
  double? pickupLng;
  double? dropLat;
  double? dropLng;

  UserRideRequestInformationModel(
      {this.pickupLatLng,
      this.dropLatLng,
      this.senderName,
      this.senderNumber,
      this.receiverName,
      this.receiverNumber,
      this.customerName,
      this.totalDistance,
      this.pickupAddress,
      this.dropAddress,
      this.customerNumber,
      this.totalTime,
      this.totalPrice,
      this.bookingId,
      this.otp,
      this.pickupLat,
      this.pickupLng,
      this.dropLat,
      this.dropLng,
      this.customerId});
}
