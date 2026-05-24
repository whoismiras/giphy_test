import 'package:giphy/features/gif_search/data/models/gif_model.dart';
import 'package:giphy/features/gif_search/domain/entities/gif_page.dart';

class GifPageModel extends GifPage {
  const GifPageModel({
    required super.gifs,
    required super.totalCount,
    required super.count,
    required super.offset,
  });

  factory GifPageModel.fromJson(Map<String, dynamic> json) {
    final gifs = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(GifModel.fromJson)
        .where((gif) => gif.id.isNotEmpty && gif.previewUrl.isNotEmpty)
        .toList();

    final pagination =
        json['pagination'] as Map<String, dynamic>? ?? const {};

    int readInt(String key, int fallback) {
      final value = pagination[key];
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return GifPageModel(
      gifs: gifs,
      totalCount: readInt('total_count', gifs.length),
      count: readInt('count', gifs.length),
      offset: readInt('offset', 0),
    );
  }
}