import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _baseUrl = 'https://ginbecc-backend.onrender.com/api/v1';

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
}

class _AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login endpoint
    if (options.path.contains('/auth/login')) {
      return handler.next(options);
    }

    final token = await StorageService.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await StorageService.instance.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false;
          return handler.next(err);
        }

        final dio = Dio(BaseOptions(baseUrl: ApiClient._baseUrl));
        final response = await dio.post(
          '/auth/refresh-token',
          options: Options(headers: {'Refresh-Token': refreshToken}),
        );

        final data = response.data['data'];
        await StorageService.instance.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        // Retry the original request with the new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${data['accessToken']}';
        final retried = await ApiClient.instance.dio.fetch(opts);
        _isRefreshing = false;
        return handler.resolve(retried);
      } catch (_) {
        _isRefreshing = false;
        await StorageService.instance.clearAll();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}