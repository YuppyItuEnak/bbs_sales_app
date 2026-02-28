import 'package:bbs_sales_app/data/models/customer/add_customer_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_address_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_group_model.dart';
import 'dart:convert';
import 'package:bbs_sales_app/data/models/customer/customer_name_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/customer/customer_model.dart';
import '../../../core/constants/api_constants.dart';

class CustomerRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<CustomerAddressModel>> fetchCustomerAddresses(
    String customerId,
    String token,
  ) async {
    final queryParams = {
      'where': 'customer_id=$customerId',
      'filter_column_is_active': 'true',
      'no_pagination': 'true',
      'include': 'm_delivery_area',
    };

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_customer_d_address',
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
      print("API Response Body: $body");
      final List data = body['data'] ?? [];

      return data.map((e) => CustomerAddressModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil alamat customer');
    }
  }

  Future<List<CustomerModel>> fetchCustomers(
    String salesId,
    String token, {
    String? search,
    int? page,
    int? paginate,
    required String unitBusinessId,
  }) async {
    final endpointUrl = '$baseUrl/dynamic/m_customer';

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

  Future<List<CustomerSimpleModel>> fetchListCustomersName(
    String token, {
    required String search,
    String? salesId,
    required String unitBusinessId,
  }) async {
    final queryParams = <String, String>{
      'selectfield': 'id,name,m_customer_group.segment_id',
      'include': 'm_customer_group,m_customer_group>m_gen',
    };

    if (search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'name';
    }

    if (salesId != null) {
      queryParams['where=sales_id'] = salesId;
    }
    queryParams['filter_column_unit_bussiness_id'] = unitBusinessId;

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_customer',
    ).replace(queryParameters: queryParams);
    print('🔗 URL: $uri');
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
      print('📥 Response body: ${response.body}');

      return data.map((e) => CustomerSimpleModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil customer');
    }
  }

  Future<List<CustomerGroup>> fetchCustomerGroups({
    required String token,
    String? search,
    required String unitBusinessId,
  }) async {
    final endpointUrl = '$baseUrl/dynamic/m_customer_group';

    final queryParams = <String, String>{
      'no_pagination': 'true',
      'selectfield': 'id,code,name,unit_bussiness_id',
      'filter_column_unit_bussiness_id': unitBusinessId,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'name,code';
    }

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

        final List<dynamic> listJson = responseData['data'] ?? [];

        return listJson.map((json) => CustomerGroup.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch customer groups',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fetch customer groups error: $e');
      }
      rethrow;
    }
  }

  Future<List<String>> fetchMGenPartnerTypes({required String token}) async {
    final endpointUrl = '$baseUrl/dynamic/m_gen';

    final queryParams = <String, String>{
      'where': "group='m_partner_type'",
      'no_pagination': 'true',
      'selectfield': 'value1',
    };

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
        final List<dynamic> listJson = responseData['data'] ?? [];
        return listJson.map((json) => json['value1'] as String).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch m_gen partner types',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fetch m_gen partner types error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required String token,
    required AddCustomerModel data,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/m_customer/with-details');
    if (kDebugMode) {
      print("Posting to $uri");
      print("Payload: ${jsonEncode(data.toJson())}");
    }

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data.toJson()),
    );

    if (kDebugMode) {
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return body['data'];
    } else {
      throw Exception('Gagal menyimpan customer: ${response.body}');
    }
  }

  Future<bool> requestApproval({
    required String token,
    required String customerId,
    required String unitBusinessId,
  }) async {
    final uri = Uri.parse('$baseUrl/fn/m_customer_approval/requestApproval');
    final payload = {
      'customer_id': customerId,
      'unit_bussiness_id': unitBusinessId,
    };

    if (kDebugMode) {
      print("Posting to $uri");
      print("Payload: ${jsonEncode(payload)}");
    }

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (kDebugMode) {
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Gagal meminta persetujuan: ${response.body}');
    }
  }
}
