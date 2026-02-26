class DeliveryAreaModel {
  final String id;
  final String code;
  final String description;

  DeliveryAreaModel({
    required this.id,
    required this.code,
    required this.description,
  });

  factory DeliveryAreaModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAreaModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
