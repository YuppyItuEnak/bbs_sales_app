class MGenModel {
  final String id;
  final String group;
  final String? key1;
  final String? value1;
  final String? value2;

  MGenModel({
    required this.id,
    required this.group,
    this.value1,
    this.value2,
    this.key1,
  });

  factory MGenModel.fromJson(Map<String, dynamic> json) {
    return MGenModel(
      id: json['id'],
      group: json['group'],
      key1: json['key1'],
      value2: json['value2'],
      value1: json['value1'],
    );
  }
}
