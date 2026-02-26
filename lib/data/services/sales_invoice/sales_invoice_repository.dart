import 'dart:convert';
import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/data/models/sales_invoice/sales_invoice_model.dart';
import 'package:bbs_sales_app/data/models/sales_invoice/sales_target_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SalesInvoiceRepository {
  Future<List<SalesInvoiceModel>> fetchSalesInvoices({
    required String token,
    required String customerId,
    int status = 4,
  }) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}/dynamic/t_sales_invoice?where=customer_id=$customerId&filter_column_status=$status',
    );
    if (kDebugMode) {
      print("URI: $uri");
    }

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Response: ${response.body}");
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> jsonList = responseData['data'] ?? [];
        return jsonList
            .map(
              (json) =>
                  SalesInvoiceModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load sales invoices: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching sales invoices: $e');
    }
  }

  Future<SalesTargetResponseModel> fetchSalesTargetComparison({
    required String token,
    required String salesId,
    required int year,
  }) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}/fn/t_sales_invoice/salesTargetComparison?sales_id=$salesId&year=$year',
    );

    if (kDebugMode) {
      print("URI: $uri");
    }

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Response: ${response.body}");
        }
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return SalesTargetResponseModel.fromJson(jsonResponse);
      } else {
        // Handle non-200 responses
        throw Exception(
          'Failed to load sales target comparison: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      throw Exception('Error fetching sales target comparison: $e');
    }
  }

  Future<SalesInvoiceModel> fetchSalesInvoiceDetail({
    required String token,
    required String id,
  }) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}/dynamic/t_sales_invoice/$id?include=t_sales_invoice_d',
    );
    if (kDebugMode) {
      print("URI: $uri");
    }

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Response: ${response.body}");
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SalesInvoiceModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to load sales invoice detail: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching sales invoice detail: $e');
    }
  }
}
