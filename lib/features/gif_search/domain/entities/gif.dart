import 'package:equatable/equatable.dart';

class Gif extends Equatable {
  const Gif({
    required this.id,
    required this.title,
    required this.previewUrl,
    required this.fullUrl,
    required this.aspectRatio,
    required this.giphyUrl,
    this.username,
  });

  final String id;
  final String title;
  final String previewUrl;
  final String fullUrl;
  final double aspectRatio;
  final String giphyUrl;
  final String? username;

  @override
  List<Object?> get props => [
    id,
    title,
    previewUrl,
    fullUrl,
    aspectRatio,
    giphyUrl,
    username,
  ];
}