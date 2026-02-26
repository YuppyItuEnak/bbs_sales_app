class ProspectModel {
  final String? id;
  final String? unitBusinessId;
  final String? code;
  final String? nameTypeId;
  final String? name;
  final String? topId;
  final String? contactPerson;
  final String? email;
  final double? latitude;
  final double? longitude;
  final bool? pn;
  final String? coaId;
  final String? phone;
  final String? salesAreaId;
  final String? salesId;
  final bool? isActive;
  final String? notes;
  final int? currentApprovalLevel;
  final int? revisedCount;
  final int? approvalCount;
  final int? approvedCount;
  final String? unitBusiness;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? requestApprovalAt;
  final String? requestApprovalBy;
  final int? status;
  final String? customerGroupName;
  final String? address;

  ProspectModel({
    this.id,
    this.unitBusinessId,
    this.code,
    this.nameTypeId,
    this.name,
    this.topId,
    this.contactPerson,
    this.email,
    this.latitude,
    this.longitude,
    this.pn,
    this.coaId,
    this.phone,
    this.salesAreaId,
    this.salesId,
    this.isActive,
    this.notes,
    this.currentApprovalLevel,
    this.revisedCount,
    this.approvalCount,
    this.approvedCount,
    this.unitBusiness,
    this.createdBy,
    this.updatedBy,
    this.requestApprovalAt,
    this.requestApprovalBy,
    this.status,
    this.customerGroupName,
    this.address,
  });

  factory ProspectModel.fromJson(Map<String, dynamic> json) {
    return ProspectModel(
      id: json['id'],
      unitBusinessId: json['unit_bussiness_id'],
      code: json['code'],
      nameTypeId: json['name_type_id'],
      name: json['name'],
      topId: json['top_id'],
      contactPerson: json['contact_person'],
      email: json['email'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      pn: json['pn'],
      coaId: json['coa_id'],
      phone: json['phone'],
      salesAreaId: json['sales_area_id'],
      salesId: json['sales_id'],
      isActive: json['is_active'],
      notes: json['notes'],
      currentApprovalLevel: json['current_approval_level'],
      revisedCount: json['revised_count'],
      approvalCount: json['approval_count'],
      approvedCount: json['approved_count'],
      unitBusiness: json['unit_bussiness'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      requestApprovalAt: json['request_approval_at'] != null
          ? DateTime.parse(json['request_approval_at'])
          : null,
      requestApprovalBy: json['request_approval_by'],
      status: json['status'],
      customerGroupName: json['customer_group_name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "unit_bussiness_id": unitBusinessId,
      "code": code,
      "name_type_id": nameTypeId,
      "name": name,
      "top_id": topId,
      "contact_person": contactPerson,
      "email": email,
      "latitude": latitude,
      "longitude": longitude,
      "pn": pn,
      "coa_id": coaId,
      "phone": phone,
      "sales_area_id": salesAreaId,
      "sales_id": salesId,
      "is_active": isActive,
      "notes": notes,
      "current_approval_level": currentApprovalLevel,
      "revised_count": revisedCount,
      "approval_count": approvalCount,
      "approved_count": approvedCount,
      "unit_bussiness": unitBusiness,
      "created_by": createdBy,
      "updated_by": updatedBy,
      "request_approval_at": requestApprovalAt?.toIso8601String(),
      "request_approval_by": requestApprovalBy,
      "status": status,
      "customer_group_name": customerGroupName,
      "address": address,
    }..removeWhere((key, value) => value == null);
  }
}
