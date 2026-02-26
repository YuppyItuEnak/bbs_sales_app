// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_sales_detail_non_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitSalesNonProspectDetail _$VisitSalesNonProspectDetailFromJson(
  Map<String, dynamic> json,
) => VisitSalesNonProspectDetail(
  id: json['id'] as String,
  visitSalesId: json['visit_sales_id'] as String?,
  customerId: json['customer_id'] as String?,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  notes: json['notes'] as String?,
  customerName: json['customer_name'] as String?,
  tVisitSale: json['t_visit_sale'] == null
      ? null
      : VisitSaleInfo.fromJson(json['t_visit_sale'] as Map<String, dynamic>),
  tVisitRealization: json['t_visit_realization'] == null
      ? null
      : VisitRealization.fromJson(
          json['t_visit_realization'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$VisitSalesNonProspectDetailToJson(
  VisitSalesNonProspectDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'visit_sales_id': instance.visitSalesId,
  'customer_id': instance.customerId,
  'date': instance.date?.toIso8601String(),
  'notes': instance.notes,
  'customer_name': instance.customerName,
  't_visit_sale': instance.tVisitSale,
  't_visit_realization': instance.tVisitRealization,
};

VisitSaleInfo _$VisitSaleInfoFromJson(Map<String, dynamic> json) =>
    VisitSaleInfo(
      id: json['id'] as String,
      code: json['code'] as String?,
      sales: json['sales'] as String?,
    );

Map<String, dynamic> _$VisitSaleInfoToJson(VisitSaleInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'sales': instance.sales,
    };

VisitRealization _$VisitRealizationFromJson(Map<String, dynamic> json) =>
    VisitRealization(
      id: json['id'] as String,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      photoStart: json['photo_start'] as String?,
      photoEnd: json['photo_end'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$VisitRealizationToJson(VisitRealization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'photo_start': instance.photoStart,
      'photo_end': instance.photoEnd,
      'notes': instance.notes,
      'status': instance.status,
    };
