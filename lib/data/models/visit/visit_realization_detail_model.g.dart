// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_realization_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitRealizationDetail _$VisitRealizationDetailFromJson(
  Map<String, dynamic> json,
) => VisitRealizationDetail(
  id: json['id'] as String,
  visitId: json['visit_id'] as String?,
  visitDate: json['visit_date'] == null
      ? null
      : DateTime.parse(json['visit_date'] as String),
  startAt: json['start_at'] as String?,
  endAt: json['end_at'] as String?,
  duration: json['duration'] as String?,
  customerName: json['customer_name'] as String?,
  notes: json['notes'] as String?,
  photoStart: json['photo_start'] as String?,
  photoEnd: json['photo_end'] as String?,
  latStart: json['lat_start'] as String?,
  longStart: json['long_start'] as String?,
  latEnd: json['lat_end'] as String?,
  longEnd: json['long_end'] as String?,
  address: json['address'] as String?,
  visitSalesDetail: json['t_visit_sales_d'] == null
      ? null
      : VisitSalesDetail.fromJson(
          json['t_visit_sales_d'] as Map<String, dynamic>,
        ),
  customer: json['m_customer'] == null
      ? null
      : CustomerSimpleModel.fromJson(
          json['m_customer'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$VisitRealizationDetailToJson(
  VisitRealizationDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'visit_id': instance.visitId,
  'visit_date': instance.visitDate?.toIso8601String(),
  'start_at': instance.startAt,
  'end_at': instance.endAt,
  'duration': instance.duration,
  'notes': instance.notes,
  'customer_name': instance.customerName,
  'photo_start': instance.photoStart,
  'photo_end': instance.photoEnd,
  'lat_start': instance.latStart,
  'long_start': instance.longStart,
  'lat_end': instance.latEnd,
  'long_end': instance.longEnd,
  'address': instance.address,
  't_visit_sales_d': instance.visitSalesDetail?.toJson(),
  'm_customer': instance.customer?.toJson(),
};
