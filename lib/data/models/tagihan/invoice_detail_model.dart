// lib/data/models/tagihan/invoice_detail_model.dart

class InvoiceDetailModel {
  final String id;
  final String customerId;
  final DateTime billingDate;
  final CustomerInfo mCustomer;
  final List<InvoiceItem> tInvoiceBillingScheduleCustDs;

  InvoiceDetailModel({
    required this.id,
    required this.customerId,
    required this.billingDate,
    required this.mCustomer,
    required this.tInvoiceBillingScheduleCustDs,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailModel(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      billingDate: json['billing_date'] != null
          ? DateTime.parse(json['billing_date'])
          : DateTime.now(),
      mCustomer: CustomerInfo.fromJson(json['m_customer'] ?? {}),
      tInvoiceBillingScheduleCustDs: (json['t_invoice_billing_schedule_cust_ds'] as List<dynamic>? ?? [])
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
    );
  }
}

class CustomerInfo {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;

  CustomerInfo({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      contactPerson: json['contact_person'] ?? 'No Contact Person',
      phone: json['phone'] ?? 'No Phone',
    );
  }
}

class InvoiceItem {
  final String id;
  final String invoiceId;
  final SalesInvoice tSalesInvoice;
  bool isSelected;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.tSalesInvoice,
    this.isSelected = true,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      tSalesInvoice: SalesInvoice.fromJson(json['t_sales_invoice'] ?? {}),
    );
  }
}

class SalesInvoice {
  final String id;
  final String code;
  final num grandTotal;

  SalesInvoice({
    required this.id,
    required this.code,
    required this.grandTotal,
  });

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: json['id'] ?? '',
      code: json['code'] ?? 'No Code',
      grandTotal: json['grand_total'] ?? 0,
    );
  }
}
