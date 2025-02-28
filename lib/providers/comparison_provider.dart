import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';

final comparisonProvider = FutureProvider((ref) async {
  final apiService = ApiService();
  Response response = await apiService.getComparisons();
  return response.data;
});
