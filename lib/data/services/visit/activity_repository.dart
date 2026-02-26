import 'dart:convert';

import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_non_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ActivityRepository {
  Future<VisitSalesNonProspectDetail?> fetchActivity(
    String token,
    String salesId,
  ) async {
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final uri = Uri.parse('${ApiConstants.baseUrl}/dynamic/t_visit_sales_d')
          .replace(
            queryParameters: {
              'include': 't_visit_sales,t_visit_realization,m_customer',
              'filter_column_t_visit_sales.id_sales': salesId,
              'where': 'date=$date',
              'order_by': 'updatedAt',
              'order_type': 'DESC',
              'paginate': '1',
            },
          );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (kDebugMode) {
        print(uri);
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("ini respon ${response.body}");
        }
        final data = json.decode(response.body);
        final List list = data['data'] ?? [];
        if (list.isNotEmpty) {
          return VisitSalesNonProspectDetail.fromJson(list[0]);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
