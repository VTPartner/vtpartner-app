class ActiveBookingModel {
  int? driverID;
  int? vehicleID;
  String? vehicleImage;
  String? vehicleName;
  String? vehicleWeight;
  String? estimatedTotalTime;
  double? estimatedTotalDistance;
  double? totalPrice;
  double? basePrice;

  ActiveBookingModel({
    this.driverID,
    this.vehicleID,
    this.vehicleImage,
    this.vehicleName,
    this.vehicleWeight,
    this.estimatedTotalTime,
    this.estimatedTotalDistance,
    this.totalPrice,
    this.basePrice,
  });
}
