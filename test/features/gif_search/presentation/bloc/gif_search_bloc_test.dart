import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giphy/core/error/failure.dart';
import 'package:giphy/core/network/network_info.dart';
import 'package:giphy/features/gif_search/data/repositories/gif_repository.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';
import 'package:giphy/features/gif_search/domain/entities/gif_page.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_bloc.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_event.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGifRepository extends Mock implements GifRepository {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

Gif _gif(String id) => Gif(
  id: id,
  title: 'GIF $id',
  previewUrl: 'https://example.com/$id-preview.gif',
  fullUrl: 'https://example.com/$id-full.gif',
  aspectRatio: 1,
  giphyUrl: 'https://giphy.com/$id',
);

GifPage _page(List<String> ids, {int totalCount = 100, int offset = 0}) =>
    GifPage(
      gifs: ids.map(_gif).toList(),
      totalCount: totalCount,
      count: ids.length,
      offset: offset,
    );

void main() {
  late _MockGifRepository repository;
  late _MockNetworkInfo networkInfo;

  setUp(() {
    repository = _MockGifRepository();
    networkInfo = _MockNetworkInfo();
    when(
      () => networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => const Stream<bool>.empty());
  });

  GifSearchBloc buildBloc() =>
      GifSearchBloc(repository: repository, networkInfo: networkInfo);

  void stubTrending({GifPage? page, Failure? error}) {
    when(
      () => repository.getTrendingGifs(
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      if (error != null) throw error;
      return page!;
    });
  }

  void stubSearch({GifPage? page, Failure? error}) {
    when(
      () => repository.searchGifs(
        query: any(named: 'query'),
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      if (error != null) throw error;
      return page!;
    });
  }

  group('GifSearchStarted', () {
    blocTest<GifSearchBloc, GifSearchState>(
      'emits [loading, success] with trending GIFs',
      build: () {
        stubTrending(page: _page(['a', 'b']));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GifSearchStartedEvent()),
      expect:
          () => [
            isA<GifSearchState>().having(
              (s) => s.status,
              'status',
              GifSearchStatus.loading,
            ),
            isA<GifSearchState>()
                .having((s) => s.status, 'status', GifSearchStatus.success)
                .having((s) => s.gifs.length, 'gifs.length', 2),
          ],
    );

    blocTest<GifSearchBloc, GifSearchState>(
      'emits [loading, failure] when the repository throws',
      build: () {
        stubTrending(error: const NetworkFailure());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GifSearchStartedEvent()),
      expect:
          () => [
            isA<GifSearchState>().having(
              (s) => s.status,
              'status',
              GifSearchStatus.loading,
            ),
            isA<GifSearchState>()
                .having((s) => s.status, 'status', GifSearchStatus.failure)
                .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
          ],
    );
  });

  group('GifQueryChanged', () {
    blocTest<GifSearchBloc, GifSearchState>(
      'debounces rapid input and searches only the final query',
      build: () {
        stubSearch(page: _page(['x']));
        return buildBloc();
      },
      act: (bloc) {
        bloc
          ..add(const GifQueryChangedEvent('c'))
          ..add(const GifQueryChangedEvent('ca'))
          ..add(const GifQueryChangedEvent('cat'));
      },
      wait: const Duration(milliseconds: 600),
      expect:
          () => [
            isA<GifSearchState>().having(
              (s) => s.status,
              'status',
              GifSearchStatus.loading,
            ),
            isA<GifSearchState>()
                .having((s) => s.status, 'status', GifSearchStatus.success)
                .having((s) => s.query, 'query', 'cat'),
          ],
      verify: (_) {
        verify(
          () => repository.searchGifs(query: 'cat', offset: 0, limit: 25),
        ).called(1);
        verifyNever(
          () => repository.searchGifs(query: 'c', offset: 0, limit: 25),
        );
      },
    );
  });

  group('GifNextPageRequested', () {
    blocTest<GifSearchBloc, GifSearchState>(
      'appends the next page to the existing GIFs',
      build: () {
        stubTrending(page: _page(['c', 'd'], offset: 2));
        return buildBloc();
      },
      seed:
          () => GifSearchState(
            status: GifSearchStatus.success,
            gifs: [_gif('a'), _gif('b')],
          ),
      act: (bloc) => bloc.add(const GifNextPageRequestedEvent()),
      expect:
          () => [
            isA<GifSearchState>().having(
              (s) => s.status,
              'status',
              GifSearchStatus.loadingMore,
            ),
            isA<GifSearchState>()
                .having((s) => s.status, 'status', GifSearchStatus.success)
                .having((s) => s.gifs.length, 'gifs.length', 4),
          ],
      verify: (_) {
        verify(
          () => repository.getTrendingGifs(offset: 2, limit: 25),
        ).called(1);
      },
    );

    blocTest<GifSearchBloc, GifSearchState>(
      'emits nothing when every page has already been loaded',
      build: buildBloc,
      seed:
          () => GifSearchState(
            status: GifSearchStatus.success,
            gifs: [_gif('a')],
            hasReachedMax: true,
          ),
      act: (bloc) => bloc.add(const GifNextPageRequestedEvent()),
      expect: () => const <GifSearchState>[],
    );
  });
}
