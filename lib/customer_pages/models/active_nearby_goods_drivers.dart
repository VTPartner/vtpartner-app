class ActiveNearByGoodsDrivers {
  int? driverId;
  double? locationLatitude;
  double? locationLongitude;
  String? driverName;
  String? driverProfilePic;
  String? vehicleImage;
  String? vehicleSizeImage;
  int? vehicleId;
  String? vehicleName;
  String? arrivalTime;
  String? arrivalDistance;
  String? vehicleWeight;
  double? perKmPrice;
  double? basePrice;

  ActiveNearByGoodsDrivers({
    required this.driverId,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.driverName,
    required this.driverProfilePic,
    required this.vehicleImage,
    required this.vehicleSizeImage,
    required this.vehicleName,
    required this.vehicleWeight,
    required this.perKmPrice,
    required this.basePrice,
    required this.vehicleId,
    this.arrivalTime,
    this.arrivalDistance,

  });

  factory ActiveNearByGoodsDrivers.fromJson(Map<String, dynamic> json) {
    return ActiveNearByGoodsDrivers(
      driverId: json['goods_driver_id'],
      locationLatitude: json['latitude'],
      locationLongitude: json['longitude'],
      driverName: json['driver_name'],
      driverProfilePic: json['driver_profile_pic'],
      vehicleImage: json['vehicle_image'],
      vehicleSizeImage: json['size_image'],
      vehicleName: json['vehicle_name'],
      vehicleWeight: json['weight'],
      perKmPrice: json['starting_price_per_km'],
      basePrice: json['base_fare'],
      vehicleId: json['vehicle_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goods_driver_id': driverId,
      'latitude': locationLatitude,
      'longitude': locationLongitude,
      'driver_name': driverName,
      'driver_profile_pic': driverProfilePic,
      'vehicle_image': vehicleImage,
      'size_image': vehicleSizeImage,
      'vehicle_name': vehicleName,
      'weight': vehicleWeight,
      'starting_price_per_km': perKmPrice,
      'base_fare': basePrice,
      'vehicle_id': vehicleId,
      'arrival_time': arrivalTime,
      'arrival_distance': arrivalDistance,
    };
  }
}
