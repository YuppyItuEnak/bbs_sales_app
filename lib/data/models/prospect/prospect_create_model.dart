class ProspectCreateModel {
  String? unitBusinessId;
  String? nameTypeId;
  String? name;
  String? topId;
  String? contactPerson;
  double? latitude;
  double? longitude;
  bool? pn;
  String? coaId;
  String? phone;
  String? salesAreaId;
  String? salesId;
  bool? isActive;
  int? currentApprovalLevel;
  int? approvalCount;
  int? approvedCount;
  String? unitBusiness;
  String? createdBy;
  int? status;
  String? customerGroupName;
  String? address;
  String? notes;

  ProspectCreateModel({
    this.unitBusinessId,
    this.nameTypeId,
    this.name,
    this.topId,
    this.contactPerson,
    this.latitude,
    this.longitude,
    this.pn,
    this.coaId = "650e6ac3-c9b3-4f66-ad8e-25262bab57a0",
    this.phone,
    this.salesAreaId,
    this.salesId,
    this.isActive = true,
    this.currentApprovalLevel = 1,
    this.approvalCount = 0,
    this.approvedCount = 0,
    this.unitBusiness,
    this.createdBy,
    this.status = 1,
    this.customerGroupName,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      "unit_bussiness_id": unitBusinessId,
      "name_type_id": nameTypeId,
      "name": name,
      "top_id": topId,
      "contact_person": contactPerson,
      "latitude": latitude,
      "longitude": longitude,
      "pn": pn,
      "coa_id": coaId,
      "phone": phone,
      "sales_area_id": salesAreaId,
      "sales_id": salesId,
      "is_active": isActive,
      "current_approval_level": currentApprovalLevel,
      "approval_count": approvalCount,
      "approved_count": approvedCount,
      "unit_bussiness": unitBusiness,
      "created_by": createdBy,
      "status": status,
      "customer_group_name": customerGroupName,
      "address": address,
      "notes": notes,
    }..removeWhere((key, value) => value == null);
  }
}
