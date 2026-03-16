import 'package:dio/dio.dart';
import 'package:expense_manager/core/network/api_endpoints.dart';
import 'package:expense_manager/core/network/dio_service.dart';
import 'package:expense_manager/domain/entities/transaction.dart';
import 'package:flutter/foundation.dart';

class TransactionRemoteSource {
  TransactionRemoteSource({required DioService dioService})
    : _dio = dioService.dio;

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await _dio.get(ApiEndpoints.getTransactions);
      final data = _handleResponse(response);
      return (data['transactions'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    } on DioException catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<String>> addTransactions(
    List<TransactionEntity> transactions,
  ) async {
    try {
      final body = transactions.map((trans) {
        return {
          'id': trans.id,
          'amount': trans.amount,
          'note': trans.note,
          'type': trans.type,
          'category_id': trans.categoryId,
          'timestamp': trans.timestamp
              .toUtc()
              .toString()
              .replaceFirst('Z', '')
              .trim(),
        };
      }).toList();

      final response = await _dio.post(
        ApiEndpoints.addTransactions,
        data: {'transactions': body},
      );
      final data = _handleResponse(response);
      return (data['synced_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } on DioException catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<String>> deleteTransactions(List<String> ids) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.deleteTransactions,
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
    final data = response.data;
    if (kDebugMode) {
      print(response.toString());
    }
    if (data is Map<String, dynamic> && data['status'] == 'success') {
      return data;
    }
    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Somehting went wrong.',
    );
  }
}
