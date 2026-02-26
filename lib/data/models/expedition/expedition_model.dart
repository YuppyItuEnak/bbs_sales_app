class ExpeditionModel {
  final String id;
  final String code;
  final String name;
  final String address;
  final String? contactPerson;
  final String? phone;
  final bool isActive;
  final String? submittedBy;
  final String? unitBussinessId;

  ExpeditionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    this.contactPerson,
    this.phone,
    required this.isActive,
    this.submittedBy,
    this.unitBussinessId,
  });

  factory ExpeditionModel.fromJson(Map<String, dynamic> json) {
    return ExpeditionModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      address: json['address'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
      isActive: json['is_active'] ?? false,
      submittedBy: json['submitted_by'],
      unitBussinessId: json['unit_bussiness_id'],
    );
  }
}
