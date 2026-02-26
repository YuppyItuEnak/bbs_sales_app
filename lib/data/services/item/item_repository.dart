import 'dart:convert';
import 'package:bbs_sales_app/data/models/item/item_model.dart';
import 'package:http/http.dart' as http;
import 'package:bbs_sales_app/core/constants/api_constants.dart';

class ItemRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<ItemModel>> fetchItems({
    required String token,
    String? itemDivisionId,
    String? search,
    int page = 1,
    int paginate = 10,
  }) async {
    final queryParams = {
      'include': 'm_pricelist,m_gen',
      'filter_column_status': 'APPROVED',
      'filter_column_is_active': 'true',
      'order_by': 'createdAt',
      'order_type': 'DESC',
      'page': page.toString(),
      'paginate': paginate.toString(),
    };

    if (itemDivisionId != null) {
      queryParams['where'] = 'item_division_id=$itemDivisionId';
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'code,name';
    }

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_item',
    ).replace(queryParameters: queryParams);

    print("Fetching items from: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Response: ${response.body}");
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => ItemModel.fromJson(e)).toList();
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      throw Exception('Gagal mengambil data item');
    }
  }

  Future<ItemModel> fetchItemDetail({
    required String token,
    required String id,
  }) async {
    final queryParams = {'include': 'm_gen'};

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_item/$id',
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
      final data = body['data'];
      return ItemModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail item');
    }
  }

  Future<double> fetchStockOnHand({
    required String token,
    required String itemId,
    required String unitBusinessId,
  }) async {
    final queryParams = {
      'item_id': itemId,
      'unit_bussiness_id': unitBusinessId,
    };

    final uri = Uri.parse(
      '$baseUrl/fn/m_item/getStockOnHandByItem',
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
      // Handle jika response dibungkus 'data' atau langsung object
      final data = body is Map && body.containsKey('data')
          ? body['data']
          : body;
      return (data['stock_on_hand'] as num?)?.toDouble() ?? 0.0;
    } else {
      throw Exception('Gagal mengambil data stock');
    }
  }
}
