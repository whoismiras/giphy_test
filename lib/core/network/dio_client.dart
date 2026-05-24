import 'package:dio/dio.dart';
import 'package:giphy/core/config/app_config.dart';

class DioClient {
  DioClient({String? apiKey, String? baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? AppConfig.giphyBaseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        ),
      ) {
    final key = apiKey ?? AppConfig.giphyApiKey;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters = {
            'api_key': key,
            ...options.queryParameters,
          };
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
}