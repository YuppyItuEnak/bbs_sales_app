import 'dart:convert';
import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/data/models/customer/customer_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_name_model.dart';
import 'package:bbs_sales_app/data/models/prospect/prospect_create_model.dart';
import 'package:bbs_sales_app/data/models/prospect/prospect_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProspectRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<ProspectModel> createProspect({
    required ProspectCreateModel prospect,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/dynamic/m_prospect');
    try {
      final body = json.encode(prospect.toJson());

      if (kDebugMode) {
        print('🔗 Creating prospect to: $url');
        print('📤 Prospect body: $body');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (kDebugMode) {
        print('📥 Prospect response status: ${response.statusCode}');
        print('📥 Prospect response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success' &&
            responseBody['data'] is Map<String, dynamic>) {
          return ProspectModel.fromJson(responseBody['data']);
        } else {
          throw Exception(
            'Failed to parse successful prospect creation response: ${response.body}',
          );
        }
      } else {
        throw Exception('Failed to create prospect: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating prospect: $e');
      }
      rethrow;
    }
  }

  Future<List<CustomerModel>> fetchListProspect(
    String salesId,
    String token, {
    String? search,
    int? page,
    int? paginate,
    required String unitBusinessId,
  }) async {
    final endpointUrl = '$baseUrl/dynamic/m_prospect';

    final queryParams = <String, String>{'filter_column_sales_id': salesId};

    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (paginate != null) {
      queryParams['paginate'] = paginate.toString();
    }
    if (search != null) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'name,code';
    }
    queryParams['filter_column_unit_bussiness_id'] = unitBusinessId;

    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> customersJson = responseData['data'] ?? [];

        return customersJson
            .map((json) => CustomerModel.fromJson(json))
            .toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch customers');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fetch customers error: $e');
      }
      rethrow;
    }
  }
}
