class CustomerAddressModel {
  final String id;
  final String address;
  final String deliveryAreaId;
  final String deliveryAreaName;
  final String name;
  final String customerId;
  final bool isDefault;
  final String notes;
  final bool isActive;

  CustomerAddressModel({
    required this.id,
    required this.address,
    required this.deliveryAreaName,
    required this.name,
    required this.customerId,
    required this.deliveryAreaId,
    required this.isDefault,
    required this.notes,
    required this.isActive,
  });

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    return CustomerAddressModel(
      id: json['id']?.toString() ?? '',
      address: json['address'] ?? '',
      deliveryAreaId: json['delivery_area_id'] ?? '',
      deliveryAreaName: json['m_delivery_area'] != null
          ? (json['m_delivery_area']['name'] ?? '')
          : '',
      name: json['name'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      notes: json['notes'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}
