import 'dart:convert';

class SalesQuotationPostModel {
  final String unitBussinessId;
  final String? code;
  final String customerId;
  final int status;
  final String? date;
  final String topId;
  final String? salesId;
  final double? total;
  final String? source;
  final String? notes;
  final String? addressId;
  final String? customerName;
  final String? unitBussiness;
  final String? sales;
  final String? shipToName;
  final String? shipToAddress;
  final String? top;
  final int? currentApprovalLevel;
  final int? revisedCount;
  final int? approvalCount;
  final int? approvedCount;
  final String? createdBy;
  final String? updatedBy;
  final String? requestApprovalBy;
  final String? requestApprovalAt;
  final String? salesArea;
  final String? deliveryAreaId;
  final String? deliveryAreaName;
  final String? expeditionId;
  final String? expeditionName;
  final String? ppnType;
  final String? ppnTypeText;
  final double? ppnValue;
  final double? dpp;
  final double? dppLainnya;
  final double? totalDiscount;
  final double? grandTotal;
  final double? ppn;
  final bool? isUsed;
  final bool? isJasa;
  final String? internalNote;
  final List<SalesQuotationDetailPostModel> tSalesQuotationDs;

  SalesQuotationPostModel({
    required this.unitBussinessId,
    this.code,
    required this.customerId,
    this.status = 1,
    this.date,
    required this.topId,
    this.salesId,
    this.total,
    this.source,
    this.notes,
    this.addressId,
    this.customerName,
    this.unitBussiness,
    this.sales,
    this.shipToName,
    this.shipToAddress,
    this.top,
    this.currentApprovalLevel,
    this.revisedCount,
    this.approvalCount,
    this.approvedCount,
    this.createdBy,
    this.updatedBy,
    this.requestApprovalBy,
    this.requestApprovalAt,
    this.salesArea,
    this.deliveryAreaId,
    this.deliveryAreaName,
    this.expeditionId,
    this.expeditionName,
    this.ppnType,
    this.ppnTypeText,
    this.ppnValue,
    this.dpp,
    this.dppLainnya,
    this.totalDiscount,
    this.grandTotal,
    this.ppn,
    this.isUsed,
    this.isJasa,
    this.internalNote,
    required this.tSalesQuotationDs,
  });

  Map<String, dynamic> toMap() {
    return {
      'unit_bussiness_id': unitBussinessId,
      'code': code,
      'customer_id': customerId,
      'status': status,
      'date': date,
      'top_id': topId,
      'sales_id': salesId,
      'total': total,
      'source': source,
      'notes': notes,
      'address_id': addressId,
      'customer_name': customerName,
      'unit_bussiness': unitBussiness,
      'sales': sales,
      'ship_to_name': shipToName,
      'ship_to_address': shipToAddress,
      'top': top,
      'current_approval_level': currentApprovalLevel,
      'revised_count': revisedCount,
      'approval_count': approvalCount,
      'approved_count': approvedCount,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'request_approval_by': requestApprovalBy,
      'request_approval_at': requestApprovalAt,
      'sales_area': salesArea,
      'delivery_area_id': deliveryAreaId,
      'delivery_area_name': deliveryAreaName,
      'expedition_id': expeditionId,
      'expedition_name': expeditionName,
      'ppn_type': ppnType,
      'ppn_type_text': ppnTypeText,
      'ppn_value': ppnValue,
      'dpp': dpp,
      'dpp_lainnya': dppLainnya,
      'total_discount': totalDiscount,
      'grand_total': grandTotal,
      'ppn': ppn,
      'is_used': isUsed,
      'is_jasa': isJasa,
      'internal_note': internalNote,
      't_sales_quotation_ds': tSalesQuotationDs.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}

class SalesQuotationDetailPostModel {
  final String? salesQuotationId;
  final String? itemId;
  final int? qty;
  final String? uomId;
  final double? price;
  final double? subtotal;
  final String? notes;
  final String? itemName;
  final double? stockOnHand;
  final String uomUnit;
  final int uomValue;
  final int qtySnapshot;
  final double? disc1;
  final double? disc2;
  final double? discAmount;
  final double? totalDisc;
  final double? totalTax;
  final double? totalAmount;

  SalesQuotationDetailPostModel({
    this.salesQuotationId,
    this.itemId,
    this.qty,
    this.uomId,
    this.price,
    this.subtotal,
    this.notes,
    this.itemName,
    this.stockOnHand,
    required this.uomUnit,
    required this.uomValue,
    required this.qtySnapshot,
    this.disc1,
    this.disc2,
    this.discAmount,
    this.totalDisc,
    this.totalTax,
    this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'sales_quotation_id': salesQuotationId,
      'item_id': itemId,
      'qty': qty,
      'uom_id': uomId,
      'price': price,
      'subtotal': subtotal,
      'notes': notes,
      'item_name': itemName,
      'stock_on_hand': stockOnHand,
      'uom_unit': uomUnit,
      'uom_value': uomValue,
      'qty_snapshot': qtySnapshot,
      'disc1': disc1,
      'disc2': disc2,
      'disc_amount': discAmount,
      'total_disc': totalDisc,
      'total_tax': totalTax,
      'total_amount': totalAmount,
    };
  }

  String toJson() => json.encode(toMap());
}
