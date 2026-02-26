import 'dart:convert';
import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/data/models/customer/delivery_area_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DeliveryAreaRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<DeliveryAreaModel>> fetchDeliveryAreas({
    required String token,
    required String unitBusinessId,
    String search = '',
  }) async {
    final queryParams = {
      'where': 'is_active=true',
      'filter_column_unit_bussiness_id': unitBusinessId,
      'search': search,
      'searchfield': 'description',
    };

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_delivery_area',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => DeliveryAreaModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data delivery area');
    }
  }
}
