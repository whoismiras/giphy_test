import 'package:flutter_test/flutter_test.dart';
import 'package:giphy/core/error/failure.dart';
import 'package:giphy/core/network/network_info.dart';
import 'package:giphy/features/gif_search/data/datasources/giphy_remote_data_source.dart';
import 'package:giphy/features/gif_search/data/models/gif_page_model.dart';
import 'package:giphy/features/gif_search/data/repositories/gif_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock implements GiphyRemoteDataSource {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late _MockRemoteDataSource remote;
  late _MockNetworkInfo network;
  late GifRepository repository;

  const page = GifPageModel(gifs: [], totalCount: 0, count: 0, offset: 0);

  setUp(() {
    remote = _MockRemoteDataSource();
    network = _MockNetworkInfo();
    repository = GifRepository(remoteDataSource: remote, networkInfo: network);
  });

  void stubSearch(Future<GifPageModel> Function() answer) {
    when(
      () => remote.searchGifs(
        query: any(named: 'query'),
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => answer());
  }

  group('searchGifs', () {
    test('throws NetworkFailure without calling the API when offline',
        () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      await expectLater(
        repository.searchGifs(query: 'cats', offset: 0, limit: 25),
        throwsA(isA<NetworkFailure>()),
      );

      verifyNever(
        () => remote.searchGifs(
          query: any(named: 'query'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('returns a page when the API call succeeds', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      stubSearch(() async => page);

      final result =
          await repository.searchGifs(query: 'cats', offset: 0, limit: 25);

      expect(result, page);
    });

    test('propagates ServerFailure thrown by the data source', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      stubSearch(
        () async => throw const ServerFailure('boom', statusCode: 500),
      );

      await expectLater(
        repository.searchGifs(query: 'cats', offset: 0, limit: 25),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('wraps unexpected errors in UnknownFailure', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      stubSearch(() async => throw StateError('boom'));

      await expectLater(
        repository.searchGifs(query: 'cats', offset: 0, limit: 25),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });
}
