import 'package:flutter_test/flutter_test.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';
import 'package:giphy/features/gif_search/domain/entities/gif_page.dart';

void main() {
  Gif gif(String id) => Gif(
    id: id,
    title: id,
    previewUrl: 'preview',
    fullUrl: 'full',
    aspectRatio: 1,
    giphyUrl: 'url',
  );

  group('GifPage.hasReachedMax', () {
    test('is false when more results remain', () {
      final page = GifPage(
        gifs: [gif('a'), gif('b')],
        totalCount: 100,
        count: 2,
        offset: 0,
      );

      expect(page.hasReachedMax, isFalse);
    });

    test('is true when loaded items cover the total count', () {
      final page = GifPage(
        gifs: [gif('a'), gif('b')],
        totalCount: 2,
        count: 2,
        offset: 0,
      );

      expect(page.hasReachedMax, isTrue);
    });

    test('is true when the page contains no GIFs', () {
      const page = GifPage(gifs: [], totalCount: 100, count: 0, offset: 50);

      expect(page.hasReachedMax, isTrue);
    });
  });
}
