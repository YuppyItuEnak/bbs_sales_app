class SalesTargetMonthModel {
  final String month;
  final int target;
  final int realisasi;
  final double percentage;

  SalesTargetMonthModel({
    required this.month,
    required this.target,
    required this.realisasi,
    required this.percentage,
  });

  factory SalesTargetMonthModel.fromJson(Map<String, dynamic> json) {
    return SalesTargetMonthModel(
      month: json['month'],
      target: json['target'],
      realisasi: json['realisasi'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class SalesTargetSummaryModel {
  final int target;
  final int realisasi;
  final double percentage;
  final int sisa;

  SalesTargetSummaryModel({
    required this.target,
    required this.realisasi,
    required this.percentage,
    required this.sisa,
  });

  factory SalesTargetSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalesTargetSummaryModel(
      target: json['target'],
      realisasi: json['realisasi'],
      percentage: (json['percentage'] as num).toDouble(),
      sisa: json['sisa'],
    );
  }
}

class SalesTargetDataModel {
  final int year;
  final SalesTargetSummaryModel summary;
  final List<SalesTargetMonthModel> months;

  SalesTargetDataModel({
    required this.year,
    required this.summary,
    required this.months,
  });

  factory SalesTargetDataModel.fromJson(Map<String, dynamic> json) {
    return SalesTargetDataModel(
      year: json['year'],
      summary: SalesTargetSummaryModel.fromJson(json['summary']),
      months: (json['months'] as List<dynamic>)
          .map((e) => SalesTargetMonthModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SalesTargetResponseModel {
  final String status;
  final SalesTargetDataModel data;

  SalesTargetResponseModel({required this.status, required this.data});

  factory SalesTargetResponseModel.fromJson(Map<String, dynamic> json) {
    return SalesTargetResponseModel(
      status: json['status'],
      data: SalesTargetDataModel.fromJson(json['data']),
    );
  }
}
