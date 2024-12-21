class AllHandyManServices {
  final int subCategoryID;
  final String subCategoryName;
  final String subCategoryImage;

  AllHandyManServices({
    required this.subCategoryID,
    required this.subCategoryName,
    required this.subCategoryImage,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory AllHandyManServices.fromJson(Map<String, dynamic> json) {
    return AllHandyManServices(
      subCategoryID: json['sub_cat_id'],
      subCategoryName: json['sub_cat_name'],
      subCategoryImage: json['image'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'sub_cat_id': subCategoryID,
      'sub_cat_name': subCategoryName,
      'image': subCategoryImage,
    };
  }
}
