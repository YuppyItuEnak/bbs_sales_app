class PaymentDetailModel {
  final String id;
  final String customerId;
  final String billingDate;
  final bool status;
  final String? note;
  final String tInvoiceBillingScheduleId;
  final String? file;
  final int totalPayment;
  final String? paymentMethod;
  final String? alasan;
  final String? lat;
  final String? long;
  final String? address;
  final String paymentDate;
  final String createdAt;
  final String updatedAt;
  final List<PaymentDetailItem> tInvoiceBillingScheduleCustDs;
  final Customer mCustomer;

  PaymentDetailModel({
    required this.id,
    required this.customerId,
    required this.billingDate,
    required this.status,
    this.note,
    required this.tInvoiceBillingScheduleId,
    this.file,
    required this.totalPayment,
    this.paymentMethod,
    this.alasan,
    this.lat,
    this.long,
    this.address,
    required this.paymentDate,
    required this.createdAt,
    required this.updatedAt,
    required this.tInvoiceBillingScheduleCustDs,
    required this.mCustomer,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailModel(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      billingDate: json['billing_date'] ?? '',
      status: json['status'] ?? false,
      note: json['note'],
      tInvoiceBillingScheduleId: json['t_invoice_billing_schedule_id'] ?? '',
      file: json['file'],
      totalPayment: json['total_payment'] ?? 0,
      paymentMethod: json['payment_method'],
      alasan: json['alasan'],
      lat: json['lat'],
      long: json['long'],
      address: json['address'],
      paymentDate: json['payment_date'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      tInvoiceBillingScheduleCustDs:
          (json['t_invoice_billing_schedule_cust_ds'] as List<dynamic>?)
              ?.map((item) => PaymentDetailItem.fromJson(item))
              .toList() ??
          [],
      mCustomer: Customer.fromJson(json['m_customer'] ?? {}),
    );
  }
}

class PaymentDetailItem {
  final String id;
  final String invoiceId;
  final String tInvoiceBillingScheduleC;
  final bool status;
  final int totalPayment;
  final String? lat;
  final String? long;
  final String? address;
  final String paymentDate;
  final String? file;
  final String createdAt;
  final String updatedAt;
  final SalesInvoice tSalesInvoice;

  PaymentDetailItem({
    required this.id,
    required this.invoiceId,
    required this.tInvoiceBillingScheduleC,
    required this.status,
    required this.totalPayment,
    this.lat,
    this.long,
    this.address,
    required this.paymentDate,
    this.file,
    required this.createdAt,
    required this.updatedAt,
    required this.tSalesInvoice,
  });

  factory PaymentDetailItem.fromJson(Map<String, dynamic> json) {
    return PaymentDetailItem(
      id: json['id'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      tInvoiceBillingScheduleC: json['t_invoice_billing_schedule_c'] ?? '',
      status: json['status'] ?? false,
      totalPayment: json['total_payment'] ?? 0,
      lat: json['lat'],
      long: json['long'],
      address: json['address'],
      paymentDate: json['payment_date'] ?? '',
      file: json['file'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      tSalesInvoice: SalesInvoice.fromJson(json['t_sales_invoice'] ?? {}),
    );
  }
}

class SalesInvoice {
  final String id;
  final String unitBussine;
  final String customerId;
  final String? sjId;
  final String salesId;
  final String taxId;
  final String date;
  final String dueDate;
  final int termin;
  final String noFaktur;
  final String headerNote;
  final String doNote;
  final int status;
  final String customer;
  final int? printCount;
  final int dpp;
  final int dpp2;
  final int totalDisc;
  final int ppnPercent;
  final int ppn;
  final int grandTotal;
  final int taxValue;
  final String code;
  final int currentAppr;
  final int revisedCoun;
  final int approvalCou;
  final int approvedCou;
  final String createdBy;
  final String updatedBy;
  final String requestAppr;
  final int grandTotal_;
  final String? cashReceipt;
  final bool isSettled;
  final int downpayment;
  final String? extDueDate;
  final bool isJasa;
  final String soId;
  final String createdAt;
  final String updatedAt;

  SalesInvoice({
    required this.id,
    required this.unitBussine,
    required this.customerId,
    this.sjId,
    required this.salesId,
    required this.taxId,
    required this.date,
    required this.dueDate,
    required this.termin,
    required this.noFaktur,
    required this.headerNote,
    required this.doNote,
    required this.status,
    required this.customer,
    this.printCount,
    required this.dpp,
    required this.dpp2,
    required this.totalDisc,
    required this.ppnPercent,
    required this.ppn,
    required this.grandTotal,
    required this.taxValue,
    required this.code,
    required this.currentAppr,
    required this.revisedCoun,
    required this.approvalCou,
    required this.approvedCou,
    required this.createdBy,
    required this.updatedBy,
    required this.requestAppr,
    required this.grandTotal_,
    this.cashReceipt,
    required this.isSettled,
    required this.downpayment,
    this.extDueDate,
    required this.isJasa,
    required this.soId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: json['id'] ?? '',
      unitBussine: json['unit_bussine'] ?? '',
      customerId: json['customer_id'] ?? '',
      sjId: json['sj_id'],
      salesId: json['sales_id'] ?? '',
      taxId: json['tax_id'] ?? '',
      date: json['date'] ?? '',
      dueDate: json['due_date'] ?? '',
      termin: json['termin'] ?? 0,
      noFaktur: json['no_faktur'] ?? '',
      headerNote: json['header_note'] ?? '',
      doNote: json['do_note'] ?? '',
      status: json['status'] ?? 0,
      customer: json['customer'] ?? '',
      printCount: json['print_count'],
      dpp: json['dpp'] ?? 0,
      dpp2: json['dpp2'] ?? 0,
      totalDisc: json['total_disc'] ?? 0,
      ppnPercent: json['ppn_percent'] ?? 0,
      ppn: json['ppn'] ?? 0,
      grandTotal: json['grand_total'] ?? 0,
      taxValue: json['tax_value'] ?? 0,
      code: json['code'] ?? '',
      currentAppr: json['current_appr'] ?? 0,
      revisedCoun: json['revised_coun'] ?? 0,
      approvalCou: json['approval_cou'] ?? 0,
      approvedCou: json['approved_cou'] ?? 0,
      createdBy: json['created_by'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      requestAppr: json['request_appr'] ?? '',
      grandTotal_: json['grand_total_'] ?? 0,
      cashReceipt: json['cash_receipt'],
      isSettled: json['is_settled'] ?? false,
      downpayment: json['downpayment'] ?? 0,
      extDueDate: json['ext_due_date'],
      isJasa: json['is_jasa'] ?? false,
      soId: json['so_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String? email;
  final String? notes;
  final String unitBussinessId;
  final String topId;
  final String nameTypeId;
  final String contactPerson;
  final bool isActive;
  final String groupId;
  final bool pn;
  final bool isThirdParty;
  final String? coaId;
  final String phone;
  final String salesAreaId;
  final String salesId;
  final String code;
  final String? latitude;
  final String? longitude;
  final String? prospekId;
  final int status;
  final String? currentApprovalLevel;
  final String? revisedCount;
  final String? approvalCount;
  final String? approvedCount;
  final String? requestApprovalAt;
  final String? requestApprovalBy;
  final String? createdBy;
  final String? updatedBy;
  final String? prospectId;
  final String createdAt;
  final String updatedAt;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.notes,
    required this.unitBussinessId,
    required this.topId,
    required this.nameTypeId,
    required this.contactPerson,
    required this.isActive,
    required this.groupId,
    required this.pn,
    required this.isThirdParty,
    this.coaId,
    required this.phone,
    required this.salesAreaId,
    required this.salesId,
    required this.code,
    this.latitude,
    this.longitude,
    this.prospekId,
    required this.status,
    this.currentApprovalLevel,
    this.revisedCount,
    this.approvalCount,
    this.approvedCount,
    this.requestApprovalAt,
    this.requestApprovalBy,
    this.createdBy,
    this.updatedBy,
    this.prospectId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      notes: json['notes'],
      unitBussinessId: json['unit_bussiness_id'] ?? '',
      topId: json['top_id'] ?? '',
      nameTypeId: json['name_type_id'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      isActive: json['is_active'] ?? false,
      groupId: json['group_id'] ?? '',
      pn: json['pn'] ?? false,
      isThirdParty: json['is_third_party'] ?? false,
      coaId: json['coa_id'],
      phone: json['phone'] ?? '',
      salesAreaId: json['sales_area_id'] ?? '',
      salesId: json['sales_id'] ?? '',
      code: json['code'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      prospekId: json['prospek_id'],
      status: json['status'] ?? 0,
      currentApprovalLevel: json['current_approval_level'],
      revisedCount: json['revised_count'],
      approvalCount: json['approval_count'],
      approvedCount: json['approved_count'],
      requestApprovalAt: json['request_approval_at'],
      requestApprovalBy: json['request_approval_by'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      prospectId: json['prospect_id'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
