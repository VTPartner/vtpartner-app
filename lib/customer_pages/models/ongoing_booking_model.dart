import 'package:google_maps_flutter/google_maps_flutter.dart';

class OngoingBookingModel {
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  String? customerName;
  String? customerId;
  String? pickupAddress;
  String? dropAddress;
  String? ratings;
  String? totalDistance;
  String? driverName;
  String? driverMobileNo;
  String? bookingTiming;
  String? paymentMethod;
  String? bookingStatus;
  String? senderName;
  String? senderNumber;
  String? receiverName;
  String? receiverNumber;
  String? vehicleName;
  String? vehiclePlateNo;
  String? vehicleFuelType;
  String? driverImage;
  String? vehicleImage;
  String? totalPrice;
  String? otp;
  String? driverId;
  double? pickupLat;
  double? pickupLng;
  double? dropLat;
  double? dropLng;

  OngoingBookingModel({
    this.pickupLatLng,
    this.dropLatLng,
    this.customerName,
    this.totalDistance,
    this.pickupAddress,
    this.dropAddress,
    this.customerId,
    this.driverName,
    this.driverMobileNo,
    this.bookingTiming,
    this.paymentMethod,
    this.ratings,
    this.bookingStatus,
    this.senderName,
    this.senderNumber,
    this.receiverName,
    this.receiverNumber,
    this.vehicleName,
    this.vehiclePlateNo,
    this.vehicleFuelType,
    this.driverImage,
    this.vehicleImage,
    this.totalPrice,
    this.otp,
    this.driverId,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
  });
}
