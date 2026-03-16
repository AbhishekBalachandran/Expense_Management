import 'package:dio/dio.dart';
import 'package:expense_manager/core/network/auth_interceptor.dart';
import 'package:expense_manager/core/storage/prefs_service.dart';

class DioService {
  late final Dio _dio;
  Dio get dio => _dio;

  DioService(PrefsService prefsService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://appskilltest.zybotech.in",
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        sendTimeout: Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(prefsService: prefsService));
  }
}
