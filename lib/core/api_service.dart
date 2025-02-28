import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000'));

  Future<Response> postRequest(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      throw Exception("Failed to connect to API");
    }
  }

  Future<Response> getRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response;
    } catch (e) {
      throw Exception("Failed to connect to API");
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Response> getProductDetails(int productId) async {
    try {
      final response = await _dio.get("/products/\$productId");
      return response;
    } catch (e) {
      throw Exception("Failed to load product details");
    }
  }

  Future<Response> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post("/products", data: productData);
      return response;
    } catch (e) {
      throw Exception("Failed to add product");
    }
  }

  Future<Response> updateProduct(
      int productId, Map<String, dynamic> productData) async {
    try {
      final response =
          await _dio.put("/products/\$productId", data: productData);
      return response;
    } catch (e) {
      throw Exception("Failed to update product");
    }
  }

  Future<Response> deleteProduct(int productId) async {
    try {
      final response = await _dio.delete("/products/\$productId");
      return response;
    } catch (e) {
      throw Exception("Failed to delete product");
    }
  }

  Future<Response> createComparison(Map<String, dynamic> comparisonData) async {
    try {
      final response = await _dio.post("/comparisons", data: comparisonData);
      return response;
    } catch (e) {
      throw Exception("Failed to create comparison");
    }
  }

  Future<Response> getComparisons() async {
    try {
      final response = await _dio.get("/comparisons");
      return response;
    } catch (e) {
      throw Exception("Failed to fetch comparisons");
    }
  }

  Future<Response> getComparisonDetails(int comparisonId) async {
    try {
      final response = await _dio.get("/comparisons/\$comparisonId");
      return response;
    } catch (e) {
      throw Exception("Failed to load comparison details");
    }
  }

  Future<Response> getSortedComparisonDetails(
      int comparisonId, String sortBy) async {
    try {
      final response = await _dio.get("/comparisons/\$comparisonId",
          queryParameters: {"sort_by": sortBy});
      return response;
    } catch (e) {
      throw Exception("Failed to load sorted comparison details");
    }
  }

  Future<Response> getCachedData(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString(endpoint);
    if (cachedData != null) {
      return Response(
          requestOptions: RequestOptions(path: endpoint), data: cachedData);
    }
    final response = await _dio.get(endpoint);
    await prefs.setString(endpoint, response.data.toString());
    return response;
  }
}
