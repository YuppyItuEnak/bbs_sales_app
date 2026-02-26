class ProspectDetailModel {
  final String? unitBusinessId;
  final String? code;
  final String? nameTypeId;
  final String? name;
  final String? topId;
  final String? contactPerson;
  final double? latitude;
  final double? longitude;
  final bool? pn;
  final String? phone;
  final String? notes;
  final String? customerGroupName;
  final String? address;

  ProspectDetailModel({
    this.unitBusinessId,
    this.code,
    this.nameTypeId,
    this.name,
    this.topId,
    this.contactPerson,
    this.latitude,
    this.longitude,
    this.pn,
    this.phone,
    this.notes,
    this.customerGroupName,
    this.address,
  });

  factory ProspectDetailModel.fromJson(Map<String, dynamic> json) {
    return ProspectDetailModel(
      unitBusinessId: json['unit_bussiness_id'],
      code: json['code'],
      nameTypeId: json['name_type_id'],
      name: json['name'],
      topId: json['top_id'],
      contactPerson: json['contact_person'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      pn: json['pn'],
      phone: json['phone'],
      notes: json['notes'],
      customerGroupName: json['customer_group_name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_bussiness_id': unitBusinessId,
      'code': code,
      'name_type_id': nameTypeId,
      'name': name,
      'top_id': topId,
      'contact_person': contactPerson,
      'latitude': latitude,
      'longitude': longitude,
      'pn': pn,
      'phone': phone,
      'notes': notes,
      'customer_group_name': customerGroupName,
      'address': address,
    };
  }
}
