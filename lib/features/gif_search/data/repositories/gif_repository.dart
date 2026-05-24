import 'package:giphy/core/error/failure.dart';
import 'package:giphy/core/network/network_info.dart';
import 'package:giphy/features/gif_search/data/datasources/giphy_remote_data_source.dart';
import 'package:giphy/features/gif_search/domain/entities/gif_page.dart';

class GifRepository {
  GifRepository({
    required GiphyRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remote = remoteDataSource,
       _network = networkInfo;

  final GiphyRemoteDataSource _remote;
  final NetworkInfo _network;

  Future<GifPage> searchGifs({
    required String query,
    required int offset,
    required int limit,
  }) {
    return _guard(
      () => _remote.searchGifs(query: query, offset: offset, limit: limit),
    );
  }

  Future<GifPage> getTrendingGifs({
    required int offset,
    required int limit,
  }) {
    return _guard(
      () => _remote.getTrendingGifs(offset: offset, limit: limit),
    );
  }

  Future<GifPage> _guard(Future<GifPage> Function() request) async {
    if (!await _network.isConnected) throw const NetworkFailure();
    try {
      return await request();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
