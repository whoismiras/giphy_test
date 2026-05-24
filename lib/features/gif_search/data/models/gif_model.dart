import 'package:giphy/features/gif_search/domain/entities/gif.dart';

class GifModel extends Gif {
  const GifModel({
    required super.id,
    required super.title,
    required super.previewUrl,
    required super.fullUrl,
    required super.aspectRatio,
    required super.giphyUrl,
    super.username,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>? ?? const {};
    final fixedWidth = images['fixed_width'] as Map<String, dynamic>?;
    final downsized = images['downsized'] as Map<String, dynamic>?;
    final original = images['original'] as Map<String, dynamic>?;

    final previewUrl =
        _url(fixedWidth) ?? _url(downsized) ?? _url(original) ?? '';
    final fullUrl = _url(original) ?? _url(downsized) ?? previewUrl;

    // Giphy sometimes returns dimensions as strings, sometimes as numbers,
    // and occasionally not at all — fall back to 1:1 when missing.
    final width =
        _dimension(fixedWidth, 'width') ?? _dimension(original, 'width');
    final height =
        _dimension(fixedWidth, 'height') ?? _dimension(original, 'height');
    final aspectRatio = (width != null && height != null && height > 0)
        ? width / height
        : 1.0;

    final title = (json['title'] as String?)?.trim();
    final username = (json['username'] as String?)?.trim();

    return GifModel(
      id: json['id'] as String? ?? '',
      title: (title == null || title.isEmpty) ? 'Untitled GIF' : title,
      previewUrl: previewUrl,
      fullUrl: fullUrl,
      aspectRatio: aspectRatio,
      giphyUrl: json['url'] as String? ?? '',
      username: (username == null || username.isEmpty) ? null : username,
    );
  }

  static String? _url(Map<String, dynamic>? rendition) {
    final url = rendition?['url'] as String?;
    return (url == null || url.isEmpty) ? null : url;
  }

  static double? _dimension(Map<String, dynamic>? rendition, String key) {
    final raw = rendition?[key];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }
}