class AddCustomerModel {
  final String name;
  final String? email;
  final String? notes;
  final String? unitBussinessId;
  final String? topId;
  final String? nameTypeId;
  final String? contactPerson;
  final bool? isActive;
  final String? groupId;
  final bool? pn;
  final String? coaId;
  final String? phone;
  final String? salesAreaId;
  final String? salesId;
  final String? code;
  final double? latitude;
  final double? longitude;
  final String? prospekId;
  final int? status;
  final int? currentApprovalLevel;
  final int? revisedCount;
  final int? approvalCount;
  final int? approvedCount;
  final DateTime? requestApprovalAt;
  final String? requestApprovalBy;
  final String? createdBy;
  final String? updatedBy;
  final bool? isThirdParty;
  final List<CustomerNPWPRequest>? npwps;
  final List<CustomerAccountRequest>? accounts;
  final List<CustomerAddressRequest>? addresses;
  final List<CustomerDocRequest>? docs;
  final List<CustomerItemFavRequest>? itemFavs;
  final List<CustomerPhoneRequest>? phones;
  final List<CustomerRestrictionRequest>? restrictions;

  AddCustomerModel({
    required this.name,
    this.email,
    this.notes,
    this.unitBussinessId,
    this.topId,
    this.nameTypeId,
    this.contactPerson,
    this.isActive,
    this.groupId,
    this.pn,
    this.coaId,
    this.phone,
    this.salesAreaId,
    this.salesId,
    this.code,
    this.latitude,
    this.longitude,
    this.prospekId,
    this.status,
    this.currentApprovalLevel,
    this.revisedCount,
    this.approvalCount,
    this.approvedCount,
    this.requestApprovalAt,
    this.requestApprovalBy,
    this.createdBy,
    this.updatedBy,
    this.isThirdParty,
    this.npwps,
    this.accounts,
    this.addresses,
    this.docs,
    this.itemFavs,
    this.phones,
    this.restrictions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'notes': notes,
      'unit_bussiness_id': unitBussinessId,
      'top_id': topId,
      'name_type_id': nameTypeId,
      'contact_person': contactPerson,
      'is_active': isActive,
      'group_id': groupId,
      'pn': pn,
      'coa_id': coaId,
      'phone': phone,
      'sales_area_id': salesAreaId,
      'sales_id': salesId,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
      'prospek_id': prospekId,
      'status': status,
      'current_approval_level': currentApprovalLevel,
      'revised_count': revisedCount,
      'approval_count': approvalCount,
      'approved_count': approvedCount,
      'request_approval_at': requestApprovalAt?.toIso8601String(),
      'request_approval_by': requestApprovalBy,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'is_third_party': isThirdParty,
      'm_customer_d_npwps': npwps?.map((e) => e.toJson()).toList(),
      'm_customer_d_accounts': accounts?.map((e) => e.toJson()).toList(),
      'm_customer_d_addresss': addresses?.map((e) => e.toJson()).toList(),
      'm_customer_d_docss': docs?.map((e) => e.toJson()).toList(),
      'm_customer_d_itemfavs': itemFavs?.map((e) => e.toJson()).toList(),
      'm_customer_d_phones': phones?.map((e) => e.toJson()).toList(),
      'm_customer_d_restrictions': restrictions
          ?.map((e) => e.toJson())
          .toList(),
    };
  }
}

class CustomerNPWPRequest {
  final String? number;
  final String? attachmentUrl;
  final String? name;
  final String? address;
  final String? notes;
  final bool? isDefault;
  final bool? isActive;
  final String? customerId;
  final String? prospectId;

  CustomerNPWPRequest({
    this.number,
    this.attachmentUrl,
    this.name,
    this.address,
    this.notes,
    this.isDefault,
    this.isActive,
    this.customerId,
    this.prospectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'attachment_url': attachmentUrl,
      'name': name,
      'address': address,
      'notes': notes,
      'is_default': isDefault,
      'is_active': isActive,
      'customer_id': customerId,
      'prospect_id': prospectId,
    };
  }
}

class CustomerAccountRequest {
  final String? bankId;
  final String? areaCode;
  final String? number;
  final String? name;
  final bool? isDefault;
  final bool? isActive;
  final String? customerId;
  final String? prospectId;

  CustomerAccountRequest({
    this.bankId,
    this.areaCode,
    this.number,
    this.name,
    this.isDefault,
    this.isActive,
    this.customerId,
    this.prospectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bank_id': bankId,
      'area_code': areaCode,
      'number': number,
      'name': name,
      'is_default': isDefault,
      'is_active': isActive,
      'customer_id': customerId,
      'prospect_id': prospectId,
    };
  }
}

class CustomerAddressRequest {
  final String? deliveryAreaId;
  final String? address;
  final String? provinceId;
  final String? cityId;
  final String? districtId;
  final String? postalCode;
  final String? notes;
  final bool? isDefault;
  final bool? isActive;
  final String? customerId;
  final String? name;
  final String? prospectId;

  CustomerAddressRequest({
    this.deliveryAreaId,
    this.address,
    this.provinceId,
    this.cityId,
    this.districtId,
    this.postalCode,
    this.notes,
    this.isDefault,
    this.isActive,
    this.customerId,
    this.name,
    this.prospectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'delivery_area_id': deliveryAreaId,
      'address': address,
      'province_id': provinceId,
      'city_id': cityId,
      'district_id': districtId,
      'postal_code': postalCode,
      'notes': notes,
      'is_default': isDefault,
      'is_active': isActive,
      'customer_id': customerId,
      'name': name,
      'prospect_id': prospectId,
    };
  }
}

class CustomerDocRequest {
  final String? docTypeId;
  final String? fileUrl;
  final String? notes;
  final String? customerId;
  final String? prospectId;

  CustomerDocRequest({
    this.docTypeId,
    this.fileUrl,
    this.notes,
    this.customerId,
    this.prospectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'doc_type_id': docTypeId,
      'file_url': fileUrl,
      'notes': notes,
      'customer_id': customerId,
      'prospect_id': prospectId,
    };
  }
}

class CustomerItemFavRequest {
  final String? itemId;
  final String? customerId;
  final String? prospectId;

  CustomerItemFavRequest({this.itemId, this.customerId, this.prospectId});

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'customer_id': customerId,
      'prospect_id': prospectId,
    };
  }
}

class CustomerPhoneRequest {
  final String? name;
  final String? phone;
  final String? customerId;
  final String? prospectId;

  CustomerPhoneRequest({
    this.name,
    this.phone,
    this.customerId,
    this.prospectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'customer_id': customerId,
      'prospect_id': prospectId,
    };
  }
}

class CustomerRestrictionRequest {
  final bool? isSq;
  final bool? isSo;
  final bool? isDo;
  final bool? isSr;
  final bool? isSi;
  final String? customerId;
  final String? prospectId;

  CustomerRestrictionRequest({
    this.isSq,
    this.isSo,
    this.isDo,
    this.isSr,
    this.isSi,
    this.customerId,
    this.prospectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_sq': isSq,
      'is_so': isSo,
      'is_do': isDo,
      'is_sr': isSr,
      'is_si': isSi,
      'customer_id': customerId,
      'prospect_id': prospectId,
    };
  }
}
