// /Users/fahmiyansyah/Polinema/QL/Flutter/bbs_sales_app/lib/data/models/tagihan/customer_billing_model.dart

class CustomerBilling {
  final String tInvoiceBillingScheduleCustId;
  final String customerId;
  final String customerName;
  final String contactPerson;
  final String phone;
  final String billingDate;
  final int totalInvoice;
  final bool isLunas;

  CustomerBilling({
    required this.tInvoiceBillingScheduleCustId,
    required this.customerId,
    required this.customerName,
    required this.contactPerson,
    required this.phone,
    required this.billingDate,
    required this.totalInvoice,
    required this.isLunas,
  });

  factory CustomerBilling.fromJson(Map<String, dynamic> json) {
    return CustomerBilling(
      tInvoiceBillingScheduleCustId:
          json['t_invoice_billing_schedule_cust_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '-',
      contactPerson: json['contact_person'] ?? '-',
      phone: json['phone'] ?? '-',
      isLunas: json['is_lunas'] ?? false,
      billingDate: json['billing_date'] ?? '',
      totalInvoice: json['total_invoice'] ?? 0,
    );
  }
}
