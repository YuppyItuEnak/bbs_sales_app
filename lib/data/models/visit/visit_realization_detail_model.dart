import 'package:json_annotation/json_annotation.dart';
import 'package:bbs_sales_app/data/models/customer/customer_name_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';

part 'visit_realization_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class VisitRealizationDetail {
  final String id;
  final String? visitId;
  final DateTime? visitDate;
  final String? startAt;
  final String? endAt;
  final String? duration;
  final String? notes;
  final String? photoStart;
  final String? customerName;
  final String? photoEnd;
  final String? latStart;
  final String? longStart;
  final String? latEnd;
  final String? longEnd;
  final String? address;

  @JsonKey(name: 't_visit_sales_d')
  final VisitSalesDetail? visitSalesDetail;

  @JsonKey(name: 'm_customer')
  final CustomerSimpleModel? customer;

  VisitRealizationDetail({
    required this.id,
    this.visitId,
    this.visitDate,
    this.startAt,
    this.endAt,
    this.duration,
    this.notes,
    this.customerName,
    this.photoStart,
    this.photoEnd,
    this.latStart,
    this.longStart,
    this.latEnd,
    this.longEnd,
    this.address,
    this.visitSalesDetail,
    this.customer,
  });

  factory VisitRealizationDetail.fromJson(Map<String, dynamic> json) =>
      _$VisitRealizationDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VisitRealizationDetailToJson(this);
}
