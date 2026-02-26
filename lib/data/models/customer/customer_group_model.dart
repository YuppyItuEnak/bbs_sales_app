class CustomerGroup {
  final String id;
  final String code;
  final String name;
  final String unitBussinessId;

  CustomerGroup({
    required this.id,
    required this.code,
    required this.name,
    required this.unitBussinessId,
  });

  factory CustomerGroup.fromJson(Map<String, dynamic> json) {
    return CustomerGroup(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      unitBussinessId: json['unit_bussiness_id'],
    );
  }
}
