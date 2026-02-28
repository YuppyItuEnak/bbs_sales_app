import 'dart:convert';
import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/data/models/visit/visit_realization_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_non_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class VisitRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<VisitSalesDetail>> fetchVisits(
    String salesId,
    String token, {
    String? search,
    String? date,
  }) async {
    final endpointUrl = '$baseUrl/dynamic/t_visit_realization';
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final queryParams = <String, String>{
      'include': 't_visit_sales_d>t_visit_sales,t_visit_sales_d,m_customer',
      'filter_column_sales_id': salesId,
      'filter_column_customer_id': 'null',
      'where': 'visit_date=$date',
      'no_pagination': 'true',
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'customer_name';
    }

    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 Fetching visits from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Visits response status: ${response.statusCode}');
        print('📥 Visits response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> responseData;

        if (decodedResponse is List) {
          responseData = decodedResponse;
        } else if (decodedResponse is Map<String, dynamic> &&
            decodedResponse['data'] is List) {
          responseData = decodedResponse['data'];
        } else {
          throw Exception(
            'Unexpected response format: ${decodedResponse.runtimeType}',
          );
        }

        return responseData
            .map((data) => VisitSalesDetail.fromJson(data))
            .toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch visits');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching visits: $e');
      }
      rethrow;
    }
  }

  Future<List<VisitSalesNonProspectDetail>> fetchVisitsNonProspect(
    String salesId,
    String token, {
    String? search,
    String? date,
  }) async {
    final endpointUrl = '$baseUrl/dynamic/t_visit_sales_d';
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final queryParams = <String, String>{
      'include':
          't_visit_sales,t_visit_realization,t_visit_realization>m_customer',
      'filter_column_t_visit_sales.id_sales': salesId,
      'where': 'date=$date',
      'no_pagination': 'true',
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'customer_name';
    }

    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 Fetching visits from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Visits response status: ${response.statusCode}');
        print('📥 Visits response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> responseData;

        if (decodedResponse is List) {
          responseData = decodedResponse;
        } else if (decodedResponse is Map<String, dynamic> &&
            decodedResponse['data'] is List) {
          responseData = decodedResponse['data'];
        } else {
          throw Exception(
            'Unexpected response format: ${decodedResponse.runtimeType}',
          );
        }

        return responseData
            .map((data) => VisitSalesNonProspectDetail.fromJson(data))
            .toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch visits');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching visits: $e');
      }
      rethrow;
    }
  }

  Future<VisitRealizationDetail> fetchVisitDetail(
    String realizationId,
    String token,
  ) async {
    final endpointUrl = '$baseUrl/dynamic/t_visit_realization/$realizationId';
    final queryParams = {
      'include': 't_visit_sales_d>t_visit_sales,t_visit_sales_d,m_customer',
    };
    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 Fetching visit detail from: $url');
      }
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Visit detail response status: ${response.statusCode}');
        print('📥 Visit detail response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data') &&
            responseBody['data'] is Map<String, dynamic>) {
          return VisitRealizationDetail.fromJson(responseBody['data']);
        } else {
          return VisitRealizationDetail.fromJson(responseBody);
        }
      } else {
        throw Exception('Failed to load visit detail: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching visit detail: $e');
      }
      rethrow;
    }
  }

  Future<VisitRealizationDetail> checkIn({
    required Map<String, String> data,
    required String photoPath,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/dynamic/t_visit_realization');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(data);

      final file = await http.MultipartFile.fromPath('photo_start', photoPath);
      request.files.add(file);

      if (kDebugMode) {
        print('🔗 Checking in to: $url');
        print('📤 Check-in fields: $data');
        print('📸 File field: ${file.field}');
        print('📂 File path: $photoPath');
        print('📦 File size: ${file.length}');
        print('📄 Filename: ${file.filename}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📥 Check-in response status: ${response.statusCode}');
        print('📥 Check-in response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success' &&
            responseBody['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> dataObject = responseBody['data'];
          return VisitRealizationDetail.fromJson(dataObject);
        } else {
          throw Exception(
            'Failed to parse successful check-in response: ${response.body}',
          );
        }
      } else {
        throw Exception('Failed to check in: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking in: $e');
      }
      rethrow;
    }
  }

  Future<bool> checkOut({
    required String realizationId,
    required Map<String, String> data,
    required String photoPath,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/dynamic/t_visit_realization/$realizationId',
    );

    try {
      var request = http.MultipartRequest('PUT', url);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields.addAll(data);
      request.files.add(
        await http.MultipartFile.fromPath('photo_end', photoPath),
      );

      if (kDebugMode) {
        print('🔗 PUT Check-out to: $url');
        print('📤 Check-out fields: $data');
        print('📸 Upload file: $photoPath');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📥 PUT Check-out response status: ${response.statusCode}');
        print('📥 Body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PUT check-out error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkRadius({
    required String customerId,
    required double latitude,
    required double longitude,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/fn/m_customer/checkRadius');
    try {
      final body = json.encode({
        'customer_id': customerId,
        'latitude': latitude,
        'longitude': longitude,
      });

      if (kDebugMode) {
        print('🔗 Checking radius from: $url');
        print('📤 Radius check body: $body');
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
        print('📥 Radius check response status: ${response.statusCode}');
        print('📥 Radius check response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check radius: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking radius: $e');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchVisitRoute(
    String salesId,
    String date,
    String token,
  ) async {
    final endpointUrl = '$baseUrl/dynamic/t_visit_realization';
    final queryParams = {
      'sales_id': salesId,
      // 'where': 'visit_date=2026-01-12',
      'where': 'visit_date=$date',
      'order_by': 'createdAt',
      'order_type': 'ASC',
      'selectfield':
          'start_at,end_at,lat_start,long_start,lat_end,long_end,address,customer_name',
    };

    final url = Uri.parse(endpointUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('🔗 Fetching route from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        // Handle if response is List or Map with data key
        final List<dynamic> data =
            (decodedResponse is Map && decodedResponse.containsKey('data'))
            ? decodedResponse['data']
            : (decodedResponse is List ? decodedResponse : []);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch route: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching route: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkOpenVisitWithoutCustomer(
    String salesId,
    String token,
  ) async {
    final url = Uri.parse(
      '$baseUrl/fn/t_visit_realization/checkOpenVisitWithoutCustomer?sales_id=$salesId',
    );

    try {
      if (kDebugMode) {
        print('🔗 Checking open visit without customer from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 Check open visit response status: ${response.statusCode}');
        print('📥 Check open visit response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check open visit: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking open visit: $e');
      }
      rethrow;
    }
  }
}
