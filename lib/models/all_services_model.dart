class AllServicesModal {
  final int categoryId;
  final String categoryName;
  final int categoryTypeId;
  final String categoryImage;
  final String categoryType;
  final String description;

  AllServicesModal({
    required this.categoryId,
    required this.categoryName,
    required this.categoryTypeId,
    required this.categoryImage,
    required this.categoryType,
    required this.description,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory AllServicesModal.fromJson(Map<String, dynamic> json) {
    return AllServicesModal(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryTypeId: json['category_type_id'],
      categoryImage: json['category_image'],
      categoryType: json['category_type'],
      description: json['description'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'category_type_id': categoryTypeId,
      'category_image': categoryImage,
      'category_type': categoryType,
      'description': description,
    };
  }
}
