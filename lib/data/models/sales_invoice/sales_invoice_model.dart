class TSalesInvoiceDsModel {
  final String? salesInvoiceId;
  final String? soId;
  final String? itemId;
  final String? itemName;
  final int? qtySj;
  final int? qtyReturn;
  final int? qtyInv;
  final String uomUnit;
  final int uomValue;
  final double? price;
  final double? amount;
  final double? disc1;
  final double? disc1Percent;
  final double? disc2;
  final double? disc2Percent;
  final double? discAmt;
  final double? totalDisc;
  final double? totalAmt;
  final String? notes;
  final String? uomId;
  final double? dpp;
  final double? dpp2;
  final double? totalTax;

  TSalesInvoiceDsModel({
    this.salesInvoiceId,
    this.soId,
    this.itemId,
    this.itemName,
    this.qtySj,
    this.qtyReturn,
    this.qtyInv,
    required this.uomUnit,
    required this.uomValue,
    this.price,
    this.amount,
    this.disc1,
    this.disc1Percent,
    this.disc2,
    this.disc2Percent,
    this.discAmt,
    this.totalDisc,
    this.totalAmt,
    this.notes,
    this.uomId,
    this.dpp,
    this.dpp2,
    this.totalTax,
  });

  factory TSalesInvoiceDsModel.fromJson(Map<String, dynamic> json) {
    return TSalesInvoiceDsModel(
      salesInvoiceId: json['sales_invoice_id'],
      soId: json['so_id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      qtySj: json['qty_sj'] is int
          ? json['qty_sj']
          : int.tryParse(json['qty_sj']!.toString()),
      qtyReturn: json['qty_return'] is int
          ? json['qty_return']
          : int.tryParse(json['qty_return']!.toString()),
      qtyInv: json['qty_inv'] is int
          ? json['qty_inv']
          : int.tryParse(json['qty_inv']!.toString()),
      uomUnit: json['uom_unit'] as String,
      uomValue: json['uom_value'] is int
          ? json['uom_value']
          : int.tryParse(json['uom_value']?.toString() ?? '0') ?? 0,
      price: (json['price'] as num?)?.toDouble(),
      amount: (json['amount'] as num?)?.toDouble(),
      disc1: (json['disc1'] as num?)?.toDouble(),
      disc1Percent: (json['disc1_percent'] as num?)?.toDouble(),
      disc2: (json['disc2'] as num?)?.toDouble(),
      disc2Percent: (json['disc2_percent'] as num?)?.toDouble(),
      discAmt: (json['disc_amt'] as num?)?.toDouble(),
      totalDisc: (json['total_disc'] as num?)?.toDouble(),
      totalAmt: (json['total_amt'] as num?)?.toDouble(),
      notes: json['notes'],
      uomId: json['uom_id'],
      dpp: (json['dpp'] as num?)?.toDouble(),
      dpp2: (json['dpp2'] as num?)?.toDouble(),
      totalTax: (json['total_tax'] as num?)?.toDouble(),
    );
  }
}

class TSalesInvoiceApprovalsModel {
  final String siId;
  final String? approvalId;
  final String? approvalDId;
  final String? userId;
  final int? level;
  final String? status;
  final bool? fullApproval;
  final String? notes;
  final DateTime? approvedAt;
  final bool? isActive;

  TSalesInvoiceApprovalsModel({
    required this.siId,
    this.approvalId,
    this.approvalDId,
    this.userId,
    this.level,
    this.status,
    this.fullApproval,
    this.notes,
    this.approvedAt,
    this.isActive,
  });

  factory TSalesInvoiceApprovalsModel.fromJson(Map<String, dynamic> json) {
    return TSalesInvoiceApprovalsModel(
      siId: json['si_id'],
      approvalId: json['approval_id'],
      approvalDId: json['approval_d_id'],
      userId: json['user_id'],
      level: json['level'],
      status: json['status'],
      fullApproval: json['full_approval'],
      notes: json['notes'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      isActive: json['is_active'],
    );
  }
}

class SalesInvoiceModel {
  final String? id;
  final String? unitBussinessId;
  final String? customerId;
  final String? sjId;
  final String? salesId;
  final String? taxId;
  final DateTime? date;
  final DateTime? dueDate;
  final int? termin;
  final String? noFaktur;
  final String? headerNote;
  final String? doNote;
  final int? status;
  final String? unitBussiness;
  final String? customer;
  final int? printCount;
  final double? dpp;
  final double? dpp2;
  final double? totalDisc;
  final double? ppnPercent;
  final double? ppn;
  final double? grandTotal;
  final double? taxValue;
  final String? code;
  final int? currentApprovalLevel;
  final int? revisedCount;
  final int? approvalCount;
  final int? approvedCount;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? requestApprovalAt;
  final String? requestApprovalBy;
  final double? grandTotalSnapshot;
  final String? cashReceiptId;
  final bool? isSettled;
  final double? downpayment;
  final int? extDueDateSi;
  final bool? isJasa;
  final String? soId;
  final List<TSalesInvoiceDsModel>? tSalesInvoiceDs;
  final List<TSalesInvoiceApprovalsModel>? tSalesInvoiceApprovals;

  SalesInvoiceModel({
    this.id,
    this.unitBussinessId,
    this.customerId,
    this.sjId,
    this.salesId,
    this.taxId,
    this.date,
    this.dueDate,
    this.termin,
    this.noFaktur,
    this.headerNote,
    this.doNote,
    this.status,
    this.unitBussiness,
    this.customer,
    this.printCount,
    this.dpp,
    this.dpp2,
    this.totalDisc,
    this.ppnPercent,
    this.ppn,
    this.grandTotal,
    this.taxValue,
    this.code,
    this.currentApprovalLevel,
    this.revisedCount,
    this.approvalCount,
    this.approvedCount,
    this.createdBy,
    this.updatedBy,
    this.requestApprovalAt,
    this.requestApprovalBy,
    this.grandTotalSnapshot,
    this.cashReceiptId,
    this.isSettled,
    this.downpayment,
    this.extDueDateSi,
    this.isJasa,
    this.soId,
    this.tSalesInvoiceDs,
    this.tSalesInvoiceApprovals,
  });

  factory SalesInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceModel(
      id: json['id'],
      unitBussinessId: json['unit_bussiness_id'],
      customerId: json['customer_id'],
      sjId: json['sj_id'],
      salesId: json['sales_id'],
      taxId: json['tax_id'],
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now()
          : null,
      termin: json['termin'] is int
          ? json['termin']
          : int.tryParse(json['termin']?.toString() ?? '0'),
      noFaktur: json['no_faktur'],
      headerNote: json['header_note'],
      doNote: json['do_note'],
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '0'),
      unitBussiness: json['unit_bussiness'],
      customer: json['customer'],
      printCount: json['print_count'] is int
          ? json['print_count']
          : int.tryParse(json['print_count']?.toString() ?? '0'),
      dpp: (json['dpp'] as num?)?.toDouble(),
      dpp2: (json['dpp2'] as num?)?.toDouble(),
      totalDisc: (json['total_disc'] as num?)?.toDouble(),
      ppnPercent: (json['ppn_percent'] as num?)?.toDouble(),
      ppn: (json['ppn'] as num?)?.toDouble(),
      grandTotal: (json['grand_total'] as num?)?.toDouble(),
      taxValue: (json['tax_value'] as num?)?.toDouble(),
      code: json['code'],
      currentApprovalLevel: json['current_approval_level'] is int
          ? json['current_approval_level']
          : int.tryParse(json['current_approval_level']?.toString() ?? '0'),
      revisedCount: json['revised_count'] is int
          ? json['revised_count']
          : int.tryParse(json['revised_count']?.toString() ?? '0'),
      approvalCount: json['approval_count'] is int
          ? json['approval_count']
          : int.tryParse(json['approval_count']?.toString() ?? '0'),
      approvedCount: json['approved_count'] is int
          ? json['approved_count']
          : int.tryParse(json['approved_count']?.toString() ?? '0'),
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      requestApprovalAt: json['request_approval_at'] != null
          ? DateTime.parse(json['request_approval_at'] as String)
          : null,
      requestApprovalBy: json['request_approval_by'],
      grandTotalSnapshot: (json['grand_total_snapshot'] as num?)?.toDouble(),
      cashReceiptId: json['cash_receipt_id'],
      isSettled: json['is_settled'],
      downpayment: (json['downpayment'] as num?)?.toDouble(),
      extDueDateSi: json['ext_due_date_si'] is int
          ? json['ext_due_date_si']
          : int.tryParse(json['ext_due_date_si']?.toString() ?? '0'),
      isJasa: json['is_jasa'],
      soId: json['so_id'],
      tSalesInvoiceDs: (json['t_sales_invoice_ds'] as List<dynamic>?)
          ?.map((e) => TSalesInvoiceDsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tSalesInvoiceApprovals:
          (json['t_sales_invoice_approvals'] as List<dynamic>?)
              ?.map(
                (e) => TSalesInvoiceApprovalsModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}
