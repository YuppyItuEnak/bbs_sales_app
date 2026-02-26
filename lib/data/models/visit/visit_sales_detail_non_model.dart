import 'package:json_annotation/json_annotation.dart';

part 'visit_sales_detail_non_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VisitSalesNonProspectDetail {
  final String id;
  final String? visitSalesId;
  final String? customerId;
  final DateTime? date;
  final String? notes;
  final String? customerName;
  @JsonKey(name: 't_visit_sale')
  final VisitSaleInfo? tVisitSale;
  @JsonKey(name: 't_visit_realization')
  final VisitRealization? tVisitRealization;

  VisitSalesNonProspectDetail({
    required this.id,
    this.visitSalesId,
    this.customerId,
    this.date,
    this.notes,
    this.customerName,
    this.tVisitSale,
    this.tVisitRealization,
  });

  factory VisitSalesNonProspectDetail.fromJson(Map<String, dynamic> json) =>
      _$VisitSalesNonProspectDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VisitSalesNonProspectDetailToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VisitSaleInfo {
  final String id;
  final String? code;
  final String? sales;

  VisitSaleInfo({
    required this.id,
    this.code,
    this.sales,
  });

  factory VisitSaleInfo.fromJson(Map<String, dynamic> json) =>
      _$VisitSaleInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VisitSaleInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VisitRealization {
  final String id;
  final String? startAt;
  final String? endAt;
  final String? photoStart;
  final String? photoEnd;
  final String? notes;
  final String? status;

  VisitRealization({
    required this.id,
    this.startAt,
    this.endAt,
    this.photoStart,
    this.photoEnd,
    this.notes,
    this.status,
  });

  factory VisitRealization.fromJson(Map<String, dynamic> json) =>
      _$VisitRealizationFromJson(json);

  Map<String, dynamic> toJson() => _$VisitRealizationToJson(this);
}
