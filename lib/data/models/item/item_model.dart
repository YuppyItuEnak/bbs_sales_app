class ItemModel {
  final String id;
  final String code;
  final String name;
  final String? itemTypeName;
  final String? itemDivisionName;
  final String? itemGroupName;
  final String? shortName;
  final String? dimension;
  final String? thickness;
  final String? length;
  final String? color;
  final String? sizeWidth;
  final String? itemKindName;
  final Pricelist? pricelist;
  final String? photo;
  final String? uom;
  final double? weightMarketing;
  final double? meter;
  final String? uomId;

  Map<String, String> get specs => {
    'Tipe Item': itemTypeName ?? '-',
    'Nama': name ?? '-',
    'Divisi': itemDivisionName ?? '-',
    'Jenis Item': itemKindName ?? '-',
    'Grup Produk': itemGroupName ?? '-',
    'Nama Pendek': shortName ?? '-',
    'Dimensi': dimension ?? '-',
    'Ketebalan': thickness ?? '-',
    'Panjang': length ?? '-',
    'Warna': color ?? '-',
    'Ukuran / Lebar': sizeWidth ?? '-',
    'Unit': uom ?? '-',
    'Berat Marketing': '${weightMarketing ?? 0} KG',
  };

  ItemModel({
    required this.id,
    required this.code,
    required this.name,
    this.itemTypeName,
    this.itemDivisionName,
    this.itemKindName,
    this.itemGroupName,
    this.pricelist,
    this.shortName,
    this.dimension,
    this.thickness,
    this.length,
    this.color,
    this.sizeWidth,
    this.photo,
    this.uom,
    this.weightMarketing,
    this.meter,
    this.uomId,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      shortName: json['alias'],
      itemTypeName: json['item_type_name'],
      uomId: json['item_uom_id'],
      dimension: json['dimension'],
      thickness: json['thickness'],
      length: json['length'],
      color: json['color'],
      sizeWidth: json['size'],
      itemKindName: json['itemKind']['value1'],
      itemDivisionName: json['item_division_name'],
      uom: json['itemUom'] != null ? json['itemUom']['value1'] : null,
      itemGroupName: json['item_group_name'],
      pricelist: json['m_pricelist'] != null
          ? Pricelist.fromJson(json['m_pricelist'])
          : null,
      photo: json['photo'],
      weightMarketing: double.tryParse(
        json['marketing_weight']?.toString() ?? '',
      ),
      meter: double.tryParse(json['meter']?.toString() ?? ''),
    );
  }

  ItemModel copyWith({
    String? id,
    String? code,
    String? name,
    String? itemTypeName,
    String? itemDivisionName,
    String? itemGroupName,
    Pricelist? pricelist,
    String? photo,
    String? uom,
    String? uomId,
    double? weightMarketing,
    double? meter,
  }) {
    return ItemModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      itemTypeName: itemTypeName ?? this.itemTypeName,
      itemDivisionName: itemDivisionName ?? this.itemDivisionName,
      itemGroupName: itemGroupName ?? this.itemGroupName,
      pricelist: pricelist ?? this.pricelist,
      uomId: uomId ?? this.uomId,
      photo: photo ?? this.photo,
      uom: uom ?? this.uom,
      weightMarketing: weightMarketing ?? this.weightMarketing,
      meter: meter ?? this.meter,
    );
  }
}

class Pricelist {
  final String id;
  final double price;
  final double priceGrosir;
  final double priceRetail;
  final double priceAgen;

  Pricelist({
    required this.id,
    required this.price,
    this.priceGrosir = 0.0,
    this.priceRetail = 0.0,
    this.priceAgen = 0.0,
  });

  factory Pricelist.fromJson(Map<String, dynamic> json) {
    return Pricelist(
      id: json['id'],
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      priceGrosir:
          double.tryParse(json['price_grosir']?.toString() ?? '') ?? 0.0,
      priceRetail:
          double.tryParse(json['price_retail']?.toString() ?? '') ?? 0.0,
      priceAgen: double.tryParse(json['price_agen']?.toString() ?? '') ?? 0.0,
    );
  }

  Pricelist copyWith({
    String? id,
    double? price,
    double? priceGrosir,
    double? priceRetail,
    double? priceAgen,
  }) {
    return Pricelist(
      id: id ?? this.id,
      price: price ?? this.price,
      priceGrosir: priceGrosir ?? this.priceGrosir,
      priceRetail: priceRetail ?? this.priceRetail,
      priceAgen: priceAgen ?? this.priceAgen,
    );
  }
}
