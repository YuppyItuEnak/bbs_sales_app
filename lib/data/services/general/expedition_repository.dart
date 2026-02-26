import 'dart:convert';
import 'package:bbs_sales_app/data/models/expedition/expedition_model.dart';
import 'package:http/http.dart' as http;
import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';


class ExpeditionRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<ExpeditionModel>> fetchExpeditions(
    String token,
    String unitBusinessId,
  ) async {
    final queryParams = {
      'where': 'unit_bussiness_id=$unitBusinessId',
      'filter_column_is_active': 'true',
      'no_pagination': 'true',
    };

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_expedition',
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
      return data.map((e) => ExpeditionModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data Ekspedisi');
    }
  }
}
