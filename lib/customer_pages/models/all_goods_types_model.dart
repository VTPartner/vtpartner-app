class AllGoodsTypesModel {
  final int goodsTypeId;
  final String goodsTypeName;

  AllGoodsTypesModel({
    required this.goodsTypeId,
    required this.goodsTypeName,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory AllGoodsTypesModel.fromJson(Map<String, dynamic> json) {
    return AllGoodsTypesModel(
      goodsTypeId: json['goods_type_id'],
      goodsTypeName: json['goods_type_name'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'goods_type_id': goodsTypeId,
      'goods_type_name': goodsTypeName,
    };
  }
}


