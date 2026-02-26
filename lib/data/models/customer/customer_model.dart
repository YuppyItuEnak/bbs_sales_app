// ignore_for_file: non_constant_identifier_names

class CustomerModel {
  final String? id;
  final String? name;
  final String? email;
  final String? notes;
  final String? unit_bussiness_id;
  final String? top_id;
  final String? name_type_id;
  final String? contact_person;
  final bool? is_active;
  final String? group_id;
  final bool? pn;
  final bool? is_third_party;
  final String? coa_id;
  final String? phone;
  final String? sales_area_id;
  final String? sales_id;
  final String? code;
  final double? latitude;
  final double? longitude;
  final String? prospek_id;
  final int? status;
  final int? current_approval_level;
  final int? revised_count;
  final int? approval_count;
  final int? approved_count;
  final DateTime? request_approval_at;
  final String? request_approval_by;
  final String? created_by;
  final String? updated_by;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CustomerNpwp> npwps;
  final List<CustomerAccount> accounts;
  final List<CustomerAddress> addresses;
  final List<CustomerDoc> docs;
  final List<CustomerItemFav> itemFavs;
  final List<CustomerPhone> phones;
  final List<CustomerRestriction> restrictions;

  // Convenience getters to match old property names
  String get contactPerson => contact_person ?? '';
  bool get isActive => is_active ?? false;
  String get groupId => group_id ?? '';
  String get nameTypeId => name_type_id ?? '';
  String get topId => top_id ?? '';
  String get unitBussinessId => unit_bussiness_id ?? '';
  String get salesAreaId => sales_area_id ?? '';
  String get salesId => sales_id ?? '';

  CustomerModel({
    this.id,
    this.name,
    this.email,
    this.notes,
    this.unit_bussiness_id,
    this.top_id,
    this.name_type_id,
    this.contact_person,
    this.is_active,
    this.group_id,
    this.pn,
    this.is_third_party,
    this.coa_id,
    this.phone,
    this.sales_area_id,
    this.sales_id,
    this.code,
    this.latitude,
    this.longitude,
    this.prospek_id,
    this.status,
    this.current_approval_level,
    this.revised_count,
    this.approval_count,
    this.approved_count,
    this.request_approval_at,
    this.request_approval_by,
    this.created_by,
    this.updated_by,
    this.createdAt,
    this.updatedAt,
    this.npwps = const [],
    this.accounts = const [],
    this.addresses = const [],
    this.docs = const [],
    this.itemFavs = const [],
    this.phones = const [],
    this.restrictions = const [],
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      notes: json['notes'],
      unit_bussiness_id: json['unit_bussiness_id'],
      top_id: json['top_id'],
      name_type_id: json['name_type_id'],
      contact_person: json['contact_person'],
      is_active: json['is_active'],
      group_id: json['group_id'],
      pn: json['pn'],
      is_third_party: json['is_third_party'],
      coa_id: json['coa_id'],
      phone: json['phone'],
      sales_area_id: json['sales_area_id'],
      sales_id: json['sales_id'],
      code: json['code'],
      latitude:
          json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      prospek_id: json['prospek_id'],
      status: json['status'],
      current_approval_level: json['current_approval_level'],
      revised_count: json['revised_count'],
      approval_count: json['approval_count'],
      approved_count: json['approved_count'],
      request_approval_at: json['request_approval_at'] != null
          ? DateTime.parse(json['request_approval_at'])
          : null,
      request_approval_by: json['request_approval_by'],
      created_by: json['created_by'],
      updated_by: json['updated_by'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      npwps: json['m_customer_d_npwps'] != null
          ? List<CustomerNpwp>.from(json['m_customer_d_npwps']
              .map((x) => CustomerNpwp.fromJson(x)))
          : [],
      accounts: json['m_customer_d_accounts'] != null
          ? List<CustomerAccount>.from(json['m_customer_d_accounts']
              .map((x) => CustomerAccount.fromJson(x)))
          : [],
      addresses: json['m_customer_d_addresss'] != null
          ? List<CustomerAddress>.from(json['m_customer_d_addresss']
              .map((x) => CustomerAddress.fromJson(x)))
          : [],
      docs: json['m_customer_d_docss'] != null
          ? List<CustomerDoc>.from(
              json['m_customer_d_docss'].map((x) => CustomerDoc.fromJson(x)))
          : [],
      itemFavs: json['m_customer_d_itemfavs'] != null
          ? List<CustomerItemFav>.from(json['m_customer_d_itemfavs']
              .map((x) => CustomerItemFav.fromJson(x)))
          : [],
      phones: json['m_customer_d_phones'] != null
          ? List<CustomerPhone>.from(json['m_customer_d_phones']
              .map((x) => CustomerPhone.fromJson(x)))
          : [],
      restrictions: json['m_customer_d_restrictions'] != null
          ? List<CustomerRestriction>.from(json['m_customer_d_restrictions']
              .map((x) => CustomerRestriction.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'notes': notes,
      'unit_bussiness_id': unit_bussiness_id,
      'top_id': top_id,
      'name_type_id': name_type_id,
      'contact_person': contact_person,
      'is_active': is_active,
      'group_id': group_id,
      'pn': pn,
      'is_third_party': is_third_party,
      'coa_id': coa_id,
      'phone': phone,
      'sales_area_id': sales_area_id,
      'sales_id': sales_id,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
      'prospek_id': prospek_id,
      'status': status,
      'current_approval_level': current_approval_level,
      'revised_count': revised_count,
      'approval_count': approval_count,
      'approved_count': approved_count,
      'request_approval_at': request_approval_at?.toIso8601String(),
      'request_approval_by': request_approval_by,
      'created_by': created_by,
      'updated_by': updated_by,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'm_customer_d_npwps': npwps.map((x) => x.toJson()).toList(),
      'm_customer_d_accounts': accounts.map((x) => x.toJson()).toList(),
      'm_customer_d_addresss': addresses.map((x) => x.toJson()).toList(),
      'm_customer_d_docss': docs.map((x) => x.toJson()).toList(),
      'm_customer_d_itemfavs': itemFavs.map((x) => x.toJson()).toList(),
      'm_customer_d_phones': phones.map((x) => x.toJson()).toList(),
      'm_customer_d_restrictions': restrictions.map((x) => x.toJson()).toList(),
    };
  }
}

class CustomerNpwp {
  final String? number;
  final String? attachment_url;
  final String? name;
  final String? address;
  final String? notes;
  final bool? is_default;
  final bool? is_active;
  final String? customer_id;
  final String? prospect_id;

  CustomerNpwp({
    this.number,
    this.attachment_url,
    this.name,
    this.address,
    this.notes,
    this.is_default,
    this.is_active,
    this.customer_id,
    this.prospect_id,
  });

  factory CustomerNpwp.fromJson(Map<String, dynamic> json) {
    return CustomerNpwp(
      number: json['number'],
      attachment_url: json['attachment_url'],
      name: json['name'],
      address: json['address'],
      notes: json['notes'],
      is_default: json['is_default'],
      is_active: json['is_active'],
      customer_id: json['customer_id'],
      prospect_id: json['prospect_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'attachment_url': attachment_url,
      'name': name,
      'address': address,
      'notes': notes,
      'is_default': is_default,
      'is_active': is_active,
      'customer_id': customer_id,
      'prospect_id': prospect_id,
    };
  }
}

class CustomerAccount {
  final String? bank_id;
  final String? area_code;
  final String? number;
  final String? name;
  final bool? is_default;
  final bool? is_active;
  final String? customer_id;
  final String? prospect_id;

  CustomerAccount({
    this.bank_id,
    this.area_code,
    this.number,
    this.name,
    this.is_default,
    this.is_active,
    this.customer_id,
    this.prospect_id,
  });

  factory CustomerAccount.fromJson(Map<String, dynamic> json) {
    return CustomerAccount(
      bank_id: json['bank_id'],
      area_code: json['area_code'],
      number: json['number'],
      name: json['name'],
      is_default: json['is_default'],
      is_active: json['is_active'],
      customer_id: json['customer_id'],
      prospect_id: json['prospect_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_id': bank_id,
      'area_code': area_code,
      'number': number,
      'name': name,
      'is_default': is_default,
      'is_active': is_active,
      'customer_id': customer_id,
      'prospect_id': prospect_id,
    };
  }
}

class CustomerAddress {
  final String? delivery_area_id;
  final String? address;
  final String? province_id;
  final String? city_id;
  final String? district_id;
  final String? postal_code;
  final String? notes;
  final bool? is_default;
  final bool? is_active;
  final String? customer_id;
  final String? name;
  final String? prospect_id;

  CustomerAddress({
    this.delivery_area_id,
    this.address,
    this.province_id,
    this.city_id,
    this.district_id,
    this.postal_code,
    this.notes,
    this.is_default,
    this.is_active,
    this.customer_id,
    this.name,
    this.prospect_id,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      delivery_area_id: json['delivery_area_id'],
      address: json['address'],
      province_id: json['province_id'],
      city_id: json['city_id'],
      district_id: json['district_id'],
      postal_code: json['postal_code'],
      notes: json['notes'],
      is_default: json['is_default'],
      is_active: json['is_active'],
      customer_id: json['customer_id'],
      name: json['name'],
      prospect_id: json['prospect_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_area_id': delivery_area_id,
      'address': address,
      'province_id': province_id,
      'city_id': city_id,
      'district_id': district_id,
      'postal_code': postal_code,
      'notes': notes,
      'is_default': is_default,
      'is_active': is_active,
      'customer_id': customer_id,
      'name': name,
      'prospect_id': prospect_id,
    };
  }
}

class CustomerDoc {
  final String? doc_type_id;
  final String? file_url;
  final String? notes;
  final String? customer_id;
  final String? prospect_id;

  CustomerDoc({
    this.doc_type_id,
    this.file_url,
    this.notes,
    this.customer_id,
    this.prospect_id,
  });

  factory CustomerDoc.fromJson(Map<String, dynamic> json) {
    return CustomerDoc(
      doc_type_id: json['doc_type_id'],
      file_url: json['file_url'],
      notes: json['notes'],
      customer_id: json['customer_id'],
      prospect_id: json['prospect_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doc_type_id': doc_type_id,
      'file_url': file_url,
      'notes': notes,
      'customer_id': customer_id,
      'prospect_id': prospect_id,
    };
  }
}

class CustomerItemFav {
  final String? item_id;
  final String? customer_id;
  final String? prospect_id;

  CustomerItemFav({this.item_id, this.customer_id, this.prospect_id});

  factory CustomerItemFav.fromJson(Map<String, dynamic> json) {
    return CustomerItemFav(
      item_id: json['item_id'],
      customer_id: json['customer_id'],
      prospect_id: json['prospect_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': item_id,
      'customer_id': customer_id,
      'prospect_id': prospect_id,
    };
  }
}

class CustomerPhone {
  final String? name;
  final String? phone;
  final String? customer_id;
  final String? prospect_id;

  CustomerPhone({this.name, this.phone, this.customer_id, this.prospect_id});

  factory CustomerPhone.fromJson(Map<String, dynamic> json) {
    return CustomerPhone(
      name: json['name'],
      phone: json['phone'],
      customer_id: json['customer_id'],
      prospect_id: json['prospect_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'customer_id': customer_id,
      'prospect_id': prospect_id,
    };
  }
}

class CustomerRestriction {
  final bool? is_sq;
  final bool? is_so;
  final bool? is_do;
  final bool? is_sr;
  final bool? is_si;
  final String? customer_id;
  final String? prospect_id;

  CustomerRestriction({
    this.is_sq,
    this.is_so,
    this.is_do,
    this.is_sr,
    this.is_si,
    this.customer_id,
    this.prospect_id,
  });

  factory CustomerRestriction.fromJson(Map<String, dynamic> json) {
    return CustomerRestriction(
      is_sq: json['is_sq'],
      is_so: json['is_so'],
      is_do: json['is_do'],
      is_sr: json['is_sr'],
      is_si: json['is_si'],
      customer_id: json['customer_id'],
      prospect_id: json['prospect_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_sq': is_sq,
      'is_so': is_so,
      'is_do': is_do,
      'is_sr': is_sr,
      'is_si': is_si,
      'customer_id': customer_id,
      'prospect_id': prospect_id,
    };
  }
}
