import 'dart:convert';
import 'dart:io';
import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/billing_history_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/customer_billing_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/invoice_detail_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/payment_detail_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/receivable_summary_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TagihanRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<MGenModel>> getGenData({
    required String token,
    required String group,
  }) async {
    String whereClause = 'group=$group';
    final url = Uri.parse(
      '$baseUrl/dynamic/m_gen',
    ).replace(queryParameters: {'where': whereClause});

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
        final List<dynamic> data = responseData['data'];
        return data.map((json) => MGenModel.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load gen data for group $group',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ getGenData error: $e');
      }
      rethrow;
    }
  }

  Future<InvoiceDetailModel> getInvoiceDetail({
    required String token,
    required String id,
  }) async {
    final url = Uri.parse(
      '$baseUrl/fn/t_invoice_billing_schedule_cust/getDetailSlim?id=$id',
    );

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
        return InvoiceDetailModel.fromJson(responseData['data']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load invoice detail',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ getInvoiceDetail error: $e');
      }
      rethrow;
    }
  }

  Future<List<CustomerBilling>> getCustomerBilling({
    required String token,
    required String salesId,
    required String startDate,
    required String endDate,
  }) async {
    final url =
        Uri.parse(
          '$baseUrl/fn/t_invoice_billing_schedule/listCustomerBillingBySales',
        ).replace(
          queryParameters: {
            'sales_id': salesId,
            'billing_date': startDate,
            'billing_date_end': endDate,
          },
        );

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
        final List<dynamic> data = responseData['data'];
        return data.map((json) => CustomerBilling.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load customer billing',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ getCustomerBilling error: $e');
      }
      rethrow;
    }
  }

  Future<ReceivableSummary> getReceivableSummary({
    required String token,
    required String customerId,
    required String startDate,
    required String endDate,
  }) async {
    final url =
        Uri.parse(
          '$baseUrl/fn/t_receivables_payment/summaryReceivableByCustomer',
        ).replace(
          queryParameters: {
            'customer_id': customerId,
            'start_date': startDate,
            'end_date': endDate,
          },
        );

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
        return ReceivableSummary.fromJson(responseData['data']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load receivable summary',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ getReceivableSummary error: $e');
      }
      rethrow;
    }
  }

  Future<List<BillingHistory>> getBillingHistory({
    required String token,
    required String customerId,
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/dynamic/t_invoice_billing_schedule_cust')
        .replace(
          queryParameters: {
            'where': 'customer_id=$customerId',
            'selectfield': 'status,total_payment,billing_date',
            'page': page.toString(),
            'limit': limit.toString(),
          },
        );

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
        final List<dynamic> data = responseData['data'];
        return data.map((json) => BillingHistory.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load billing history',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ getBillingHistory error: $e');
      }
      rethrow;
    }
  }

  Future<String?> uploadFile({
    required String token,
    required File file,
  }) async {
    final url = Uri.parse('$baseUrl/dynamic/upload_file');
    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('path_file', file.path),
    );

    try {
      if (kDebugMode) {
        print('🔗 Upload URL: $url');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print('📥 Upload Response status: ${response.statusCode}');
        print('📥 Upload Response body: $responseBody');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          return responseData['data']['path_file'];
        } else {
          throw Exception('Upload failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ uploadFile error: $e');
      }
      rethrow;
    }
  }

  Future<void> submitPayment({
    required String token,
    required String billingScheduleCustId,
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse(
      '$baseUrl/dynamic/t_invoice_billing_schedule_cust/with-details/$billingScheduleCustId',
    );

    try {
      if (kDebugMode) {
        print('🔗 URL: $url');
        print('📤 Payload: ${json.encode(payload)}');
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Success
        return;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit payment');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ submitPayment error: $e');
      }
      rethrow;
    }
  }

  Future<PaymentDetailModel> getPaymentDetail({
    required String token,
    required String id,
  }) async {
    final url = Uri.parse(
      '$baseUrl/dynamic/t_invoice_billing_schedule_cust/$id?include=t_invoice_billing_schedule_cust_d,m_customer,t_invoice_billing_schedule_cust_d%3Et_sales_invoice',
    );

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
        return PaymentDetailModel.fromJson(responseData['data']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load payment detail',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ getPaymentDetail error: $e');
      }
      rethrow;
    }
  }
}
