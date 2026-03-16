import 'package:dio/dio.dart';
import 'package:expense_manager/core/network/dio_service.dart';
import 'package:flutter/foundation.dart';

class AuthRemoteSource {
  final Dio _dio;
  AuthRemoteSource({required DioService dioService}) : _dio = dioService.dio;

  // handle response
  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (kDebugMode) {
        print(response.realUri);
        print(data.toString());
      }
      if (data['status'] == 'success') return data;
      throw Exception(data['message'] ?? 'Something went wrong.');
    }
    throw Exception('Unexpected response format.');
  }

  // handle error
  String _handleErro(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Server error. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  // send otp
  Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    try {
      final response = await _dio.post(
        '/auth/send-otp/',
        data: {'phone': phone},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleErro(e));
    }
  }

  // create account
  Future<Map<String, dynamic>> createAccount({
    required String phone,
    required String nickname,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/create-account/',
        data: {'phone': phone, 'nickname': nickname},
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleErro(e));
    }
  }
}
