class BillingHistory {
  final bool? status;
  final int? totalPayment;
  final String billingDate;

  BillingHistory({
    required this.status,
    required this.totalPayment,
    required this.billingDate,
  });

  factory BillingHistory.fromJson(Map<String, dynamic> json) {
    return BillingHistory(
      status: json['status'],
      totalPayment: json['total_payment'],
      billingDate: json['billing_date'],
    );
  }
}
