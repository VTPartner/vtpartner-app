class ActiveNearByGoodsDrivers {
  int? driverId;
  double? locationLatitude;
  double? locationLongitude;
  String? driverName;
  String? driverProfilePic;
  String? vehicleImage;
  String? vehicleName;

  ActiveNearByGoodsDrivers({
    required this.driverId,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.driverName,
    required this.driverProfilePic,
    required this.vehicleImage,
    required this.vehicleName,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory ActiveNearByGoodsDrivers.fromJson(Map<String, dynamic> json) {
    return ActiveNearByGoodsDrivers(
      driverId: json['goods_driver_id'],
      locationLatitude: json['latitude'],
      locationLongitude: json['longitude'],
      driverName: json['driver_name'],
      driverProfilePic: json['driver_profile_pic'],
      vehicleImage: json['vehicle_image'],
      vehicleName: json['vehicle_name'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'goods_driver_id': driverId,
      'latitude': locationLatitude,
      'longitude': locationLongitude,
      'driver_name': driverName,
      'driver_profile_pic': driverProfilePic,
      'vehicle_image': vehicleImage,
      'vehicle_name': vehicleName,
    };
  }
}
