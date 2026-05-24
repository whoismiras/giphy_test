import 'package:flutter_test/flutter_test.dart';
import 'package:giphy/features/gif_search/data/models/gif_model.dart';

void main() {
  group('GifModel.fromJson', () {
    test('parses a complete Giphy GIF object', () {
      final json = <String, dynamic>{
        'id': 'abc123',
        'title': 'Happy Dance',
        'username': 'dancer',
        'url': 'https://giphy.com/gifs/abc123',
        'images': {
          'fixed_width': {
            'url': 'https://media.giphy.com/fixed_width.gif',
            'width': '200',
            'height': '150',
          },
          'original': {
            'url': 'https://media.giphy.com/original.gif',
            'width': '480',
            'height': '360',
          },
        },
      };

      final gif = GifModel.fromJson(json);

      expect(gif.id, 'abc123');
      expect(gif.title, 'Happy Dance');
      expect(gif.username, 'dancer');
      expect(gif.giphyUrl, 'https://giphy.com/gifs/abc123');
      expect(gif.previewUrl, 'https://media.giphy.com/fixed_width.gif');
      expect(gif.fullUrl, 'https://media.giphy.com/original.gif');
      expect(gif.aspectRatio, closeTo(200 / 150, 0.0001));
    });

    test('falls back to a placeholder title when the title is empty', () {
      final json = <String, dynamic>{
        'id': 'no-title',
        'title': '',
        'url': 'https://giphy.com/gifs/no-title',
        'images': {
          'fixed_width': {
            'url': 'https://media.giphy.com/fw.gif',
            'width': '100',
            'height': '100',
          },
        },
      };

      final gif = GifModel.fromJson(json);

      expect(gif.title, 'Untitled GIF');
      expect(gif.username, isNull);
    });

    test('defaults the aspect ratio to 1.0 when dimensions are missing', () {
      final json = <String, dynamic>{
        'id': 'no-dims',
        'title': 'X',
        'url': '',
        'images': {
          'fixed_width': {'url': 'https://media.giphy.com/fw.gif'},
        },
      };

      final gif = GifModel.fromJson(json);

      expect(gif.aspectRatio, 1.0);
    });

    test('falls back to other renditions when fixed_width is absent', () {
      final json = <String, dynamic>{
        'id': 'fallback',
        'title': 'Fallback',
        'url': '',
        'images': {
          'original': {
            'url': 'https://media.giphy.com/original.gif',
            'width': '480',
            'height': '240',
          },
        },
      };

      final gif = GifModel.fromJson(json);

      expect(gif.previewUrl, 'https://media.giphy.com/original.gif');
      expect(gif.fullUrl, 'https://media.giphy.com/original.gif');
      expect(gif.aspectRatio, closeTo(2.0, 0.0001));
    });
  });
}
