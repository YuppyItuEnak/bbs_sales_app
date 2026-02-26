class ReceivableSummary {
  final String customerId;
  final String customerName;
  final int totalPiutang;
  final int totalTerbayar;
  final int sisaPiutang;

  ReceivableSummary({
    required this.customerId,
    required this.customerName,
    required this.totalPiutang,
    required this.totalTerbayar,
    required this.sisaPiutang,
  });

  factory ReceivableSummary.fromJson(Map<String, dynamic> json) {
    return ReceivableSummary(
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '-',
      totalPiutang: json['total_piutang'] ?? 0,
      totalTerbayar: json['total_terbayar'] ?? 0,
      sisaPiutang: json['sisa_piutang'] ?? 0,
    );
  }
}
