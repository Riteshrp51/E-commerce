import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/product_model.dart';
import 'sample_catalog.dart';

class ProductService {
  Future<List<ProductModel>> fetchProducts({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        queryParams['category'] = category;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      String url = ApiConstants.products;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$query';
      }

      final response = await ApiClient.get(url);
      final List<dynamic> data = response['data'] ?? [];
      final products = data.map((json) => ProductModel.fromJson(json)).toList();

      if (products.isNotEmpty) {
        return products;
      }
    } catch (e) {
      debugPrint('Live product API fetch failed: $e. Serving local fallback catalog.');
    }

    // Resilient Fallback: Filter local sample catalog so screen is never blank
    return _filterFallbackCatalog(category: category, search: search);
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await ApiClient.get(ApiConstants.categories);
      final List<dynamic> cats = response['categories'] ?? [];
      final list = cats.map((e) => e.toString()).toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return [
      'Vegetables',
      'Fruits',
      'Dairy',
      'Drinks',
      'Grains',
      'Bakery',
      'Instant',
    ];
  }

  Future<ProductModel> fetchProductById(String id) async {
    try {
      final response = await ApiClient.get(ApiConstants.productDetails(id));
      return ProductModel.fromJson(response['data']);
    } catch (_) {
      return fallbackCatalog.firstWhere(
        (p) => p.id == id,
        orElse: () => fallbackCatalog.first,
      );
    }
  }

  List<ProductModel> _filterFallbackCatalog({String? category, String? search}) {
    var list = fallbackCatalog;

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      list = list.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q)
      ).toList();
    }

    return list;
  }
}
