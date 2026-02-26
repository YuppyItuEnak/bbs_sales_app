// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_sales_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitSalesDetail _$VisitSalesDetailFromJson(Map<String, dynamic> json) =>
    VisitSalesDetail(
      id: json['id'] as String,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?,
      // Map 'visit_date' ke field date atau sesuaikan di model utama
      visitDate: json['visit_date'] as String?,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      photoStart: json['photo_start'] as String?,
      photoEnd: json['photo_end'] as String?,
      latStart: json['lat_start'] as String?,
      longStart: json['long_start'] as String?,
      latEnd: json['lat_end'] as String?,
      longEnd: json['long_end'] as String?,
      address: json['address'] as String?,
      salesId: json['sales_id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$VisitSalesDetailToJson(VisitSalesDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'visit_date': instance.visitDate,
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'status': instance.status,
      'notes': instance.notes,
      'photo_start': instance.photoStart,
      'photo_end': instance.photoEnd,
      'lat_start': instance.latStart,
      'long_start': instance.longStart,
      'lat_end': instance.latEnd,
      'long_end': instance.longEnd,
      'address': instance.address,
      'sales_id': instance.salesId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
