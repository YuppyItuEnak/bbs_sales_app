class QuotationDetail {
  final String id;
  final String? unitBussinessId;
  final String code;
  final String? customerId;
  final String customerName;
  final int status;
  final String date;
  final String? topId;
  final String? top;
  final String? salesId;
  final double total;
  final String source;
  final String? notes;
  final String? internalNote;
  final String? addressId;
  final String? unitBussiness;
  final String? sales;
  final String? shipToName;
  final String? shipToAddress;
  final String? deliveryAreaId;
  final String? deliveryAreaName;
  final String? expeditionId;
  final String? expeditionName;
  final String ppnType;
  final String ppnTypeText;
  final double ppnValue;
  final double dpp;
  final double dppLainnya;
  final double totalDiscount;
  final double ppn;
  final double grandTotal;
  final bool isUsed;
  final List<QuotationDetailItem> items;

  QuotationDetail({
    required this.id,
    this.unitBussinessId,
    required this.code,
    this.customerId,
    required this.customerName,
    required this.status,
    required this.date,
    this.topId,
    this.top,
    this.salesId,
    required this.total,
    required this.source,
    this.notes,
    this.internalNote,
    this.addressId,
    this.unitBussiness,
    this.sales,
    this.shipToName,
    this.shipToAddress,
    this.deliveryAreaId,
    this.deliveryAreaName,
    this.expeditionId,
    this.expeditionName,
    required this.ppnType,
    required this.ppnTypeText,
    required this.ppnValue,
    required this.dpp,
    required this.dppLainnya,
    required this.totalDiscount,
    required this.ppn,
    required this.grandTotal,
    required this.isUsed,
    required this.items,
  });

  factory QuotationDetail.fromJson(Map<String, dynamic> json) {
    var list = json['t_sales_quotation_ds'] as List? ?? [];
    List<QuotationDetailItem> itemsList = list
        .map((i) => QuotationDetailItem.fromJson(i))
        .toList();

    final topData = json['salesQuotationTop'];
    final addressData = json['m_customer_d_address'];

    return QuotationDetail(
      id: json['id'] ?? '',
      unitBussinessId: json['unit_bussiness_id'],
      code: json['code'] ?? '',
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? '',
      status: int.tryParse('${json['status']}') ?? 1,
      date: json['date'] ?? '',
      topId: json['top_id'],
      top: topData != null ? topData['value1'] : json['top'],
      salesId: json['sales_id'],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] ?? 'apps',
      notes: json['notes'],
      internalNote: json['internal_note'],
      deliveryAreaId: json['delivery_area_id'],
      deliveryAreaName: json['delivery_area_name'],
      addressId: json['address_id'],
      unitBussiness: json['unit_bussiness'],
      sales: json['sales'],
      shipToName: json['ship_to_name'],
      shipToAddress:
          json['ship_to_address'] ??
          (addressData != null && addressData['m_delivery_area'] != null
              ? addressData['m_delivery_area']['name']
              : null),
      expeditionId: json['expedition_id'],
      expeditionName: json['expedition_name'],
      ppnType: json['ppn_type'] ?? '',
      ppnTypeText: json['ppn_type_text'] ?? '',
      ppnValue: (json['ppn_value'] as num?)?.toDouble() ?? 0.0,
      dpp: (json['dpp'] as num?)?.toDouble() ?? 0.0,
      dppLainnya: (json['dpp_lainnya'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
      ppn: (json['ppn'] as num?)?.toDouble() ?? 0.0,
      grandTotal:
          (json['grand_total'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
      isUsed: json['is_used'] ?? false,
      items: itemsList,
    );
  }
}

class QuotationDetailItem {
  final String id;
  final String itemId;
  final String itemName;
  final String itemCode;
  final double qty;
  final String uom;
  final String? uomId;
  final String? uomUnit;
  final double price;
  final double subtotal;
  final double disc1;
  final double discAmount;
  final double totalDisc;
  final double totalTax;
  final double totalAmount;
  final String? notes;

  QuotationDetailItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.qty,
    required this.uomId,
    required this.uom,
    this.uomUnit,
    required this.price,
    required this.subtotal,
    required this.disc1,
    required this.discAmount,
    required this.totalDisc,
    required this.totalTax,
    required this.totalAmount,
    this.notes,
  });

  factory QuotationDetailItem.fromJson(Map<String, dynamic> json) {
    String code = '';
    String itemId = '';
    String uom = '';
    String? uomUnit;

    if (json['m_item'] != null) {
      code = json['m_item']['code'] ?? '';
      itemId = json['m_item']['id'] ?? '';
    }

    if (json['m_uom'] != null) {
      uom = json['m_uom']['name'] ?? '';
      uomUnit = json['m_uom']['code'] ?? '';
    }

    return QuotationDetailItem(
      id: json['id'] ?? '',
      itemId: itemId,
      itemName: json['item_name'] ?? '',
      uomId: json['uom_id'],
      itemCode: code,
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      uom: uom.isEmpty ? '' : uom,
      uomUnit: uomUnit,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      disc1: (json['disc1'] as num?)?.toDouble() ?? 0.0,
      discAmount: (json['disc_amount'] as num?)?.toDouble() ?? 0.0,
      totalDisc: (json['total_disc'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }
}
