import 'package:json_annotation/json_annotation.dart';

part 'visit_sales_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VisitSalesDetail {
  final String id;
  final String? customerId;
  final String? customerName;
  final String? visitDate;
  final String? startAt;
  final String? endAt;
  final String? status;
  final String? notes;
  final String? photoStart;
  final String? photoEnd;
  final String? latStart;
  final String? longStart;
  final String? latEnd;
  final String? longEnd;
  final String? address;
  final String? salesId;
  final String? createdAt;
  final String? updatedAt;

  // Tetap pertahankan field lama jika diperlukan untuk compatibility
  // Namun berdasarkan JSON Anda, data sekarang berada di root level
  final String? duration;
  final String? prospectId;

  VisitSalesDetail({
    required this.id,
    this.customerId,
    this.customerName,
    this.visitDate,
    this.startAt,
    this.endAt,
    this.status,
    this.notes,
    this.photoStart,
    this.photoEnd,
    this.latStart,
    this.longStart,
    this.latEnd,
    this.longEnd,
    this.address,
    this.salesId,
    this.createdAt,
    this.updatedAt,
    this.duration,
    this.prospectId,
  });

  factory VisitSalesDetail.fromJson(Map<String, dynamic> json) =>
      _$VisitSalesDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VisitSalesDetailToJson(this);
}
