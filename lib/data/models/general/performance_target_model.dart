class PerformanceTargetMonthModel {
  final String month;
  final int target;
  final int realisasi;
  final double percentage;

  PerformanceTargetMonthModel({
    required this.month,
    required this.target,
    required this.realisasi,
    required this.percentage,
  });

  factory PerformanceTargetMonthModel.fromJson(Map<String, dynamic> json) {
    return PerformanceTargetMonthModel(
      month: json['month'],
      target: json['target'] is int
          ? json['target']
          : int.tryParse(json['target']?.toString() ?? '0') ?? 0,
      realisasi: json['realisasi'] is int
          ? json['realisasi']
          : int.tryParse(json['realisasi']?.toString() ?? '0') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PerformanceTargetSummaryModel {
  final int target;
  final int realisasi;
  final double percentage;

  PerformanceTargetSummaryModel({
    required this.target,
    required this.realisasi,
    required this.percentage,
  });

  factory PerformanceTargetSummaryModel.fromJson(Map<String, dynamic> json) {
    return PerformanceTargetSummaryModel(
      target: json['target'] is int
          ? json['target']
          : int.tryParse(json['target']?.toString() ?? '0') ?? 0,
      realisasi: json['realisasi'] is int
          ? json['realisasi']
          : int.tryParse(json['realisasi']?.toString() ?? '0') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PerformanceTargetDataModel {
  final String salesId;
  final int year;
  final PerformanceTargetSummaryModel summary;
  final List<PerformanceTargetMonthModel> months;

  PerformanceTargetDataModel({
    required this.salesId,
    required this.year,
    required this.summary,
    required this.months,
  });

  factory PerformanceTargetDataModel.fromJson(Map<String, dynamic> json) {
    return PerformanceTargetDataModel(
      salesId: json['sales_id'] ?? '',
      year: json['year'] is int
          ? json['year']
          : int.tryParse(
                  json['year']?.toString() ?? DateTime.now().year.toString(),
                ) ??
                DateTime.now().year,
      summary: PerformanceTargetSummaryModel.fromJson(json['summary'] ?? {}),
      months:
          (json['months'] as List<dynamic>?)
              ?.map(
                (e) => PerformanceTargetMonthModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
