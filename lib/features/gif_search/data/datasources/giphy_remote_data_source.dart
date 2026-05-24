import 'package:dio/dio.dart';
import 'package:giphy/core/error/failure.dart';
import 'package:giphy/features/gif_search/data/models/gif_page_model.dart';

class GiphyRemoteDataSource {
  GiphyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<GifPageModel> searchGifs({
    required String query,
    required int offset,
    required int limit,
  }) {
    return _getPage('/gifs/search', {
      'q': query,
      'limit': limit,
      'offset': offset,
      'rating': 'g',
      'lang': 'en',
    });
  }

  Future<GifPageModel> getTrendingGifs({
    required int offset,
    required int limit,
  }) {
    return _getPage('/gifs/trending', {
      'limit': limit,
      'offset': offset,
      'rating': 'g',
    });
  }

  Future<GifPageModel> _getPage(
    String path,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data == null) throw const ServerFailure('Empty response from Giphy.');
      return GifPageModel.fromJson(data);
    } on DioException catch (error) {
      throw _failureFromDio(error);
    }
  }

  Failure _failureFromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure('Unable to reach Giphy.');
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return ServerFailure(_messageForStatus(code), statusCode: code);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ServerFailure('Unexpected error contacting Giphy.');
    }
  }

  String _messageForStatus(int? code) {
    return switch (code) {
      null => 'Giphy request failed.',
      401 || 403 => 'Invalid or missing Giphy API key.',
      429 => 'Giphy rate limit reached. Please wait a moment.',
      >= 500 => 'Giphy is temporarily unavailable. Please try again.',
      _ => 'Giphy request failed (status $code).',
    };
  }
}