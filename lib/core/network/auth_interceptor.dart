import 'package:dio/dio.dart';
import 'package:expense_manager/core/storage/prefs_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required PrefsService prefsService}) : _prefs = prefsService;

  final PrefsService _prefs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getToken();
    if (token != null &&
        token.isNotEmpty &&
        !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    return handler.next(err);
  }
}
