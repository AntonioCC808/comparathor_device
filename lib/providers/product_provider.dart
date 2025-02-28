import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';

final productProvider = FutureProvider((ref) async {
  final apiService = ApiService();
  Response response = await apiService.getRequest("/products");
  return response.data; // List of products
});
