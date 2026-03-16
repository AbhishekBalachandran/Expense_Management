import 'package:dio/dio.dart';
import 'package:expense_manager/core/network/api_endpoints.dart';
import 'package:expense_manager/core/network/dio_service.dart';
import 'package:expense_manager/domain/entities/category.dart';
import 'package:flutter/foundation.dart';

class CategoryRemoteSource {
  CategoryRemoteSource({required DioService dioService})
    : _dio = dioService.dio;
  final Dio _dio;

  Future<List<CategoryEntity>> getCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.getCategories);
      final data = _handleResponse(response);
      final list = data['categories'] as List<dynamic>? ?? [];
      return list.map((category) {
        return CategoryEntity(
          id: category['id'] as String,
          name: category['name'] as String,
          isSynced: 1,
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<String>> addCategories(List<CategoryEntity> categories) async {
    try {
      final syncedIds = <String>[];
      for (final category in categories) {
        final response = await _dio.post(
          ApiEndpoints.addCategories,
          data: {'category_id': category.id, 'name': category.name},
        );
        final data = _handleResponse(response);
        final ids =
            (data['synced_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        syncedIds.addAll(ids);
      }
      return syncedIds;
    } on DioException catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<String>> deleteCategories(List<String> ids) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.deleteCategories,
        data: {'ids': ids},
      );
      final data = _handleResponse(response);
      return (data['deleted_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } on DioException catch (e) {
      throw Exception(e.toString());
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (kDebugMode) {
      print(response.toString());
    }
    final data = response.data;
    if (data is Map<String, dynamic> && data['status'] == 'success') {
      return data;
    }
    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Somthing went wrong.',
    );
  }
}
