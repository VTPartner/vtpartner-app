class AllHandyManSubServices {
  final int serviceID;
  final String serviceName;
  final String serviceImage;

  AllHandyManSubServices({
    required this.serviceID,
    required this.serviceName,
    required this.serviceImage,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory AllHandyManSubServices.fromJson(Map<String, dynamic> json) {
    return AllHandyManSubServices(
      serviceID: json['service_id'],
      serviceName: json['service_name'],
      serviceImage: json['service_image'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceID,
      'service_name': serviceName,
      'service_image': serviceImage,
    };
  }
}
