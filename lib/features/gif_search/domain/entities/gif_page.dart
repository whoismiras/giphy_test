import 'package:equatable/equatable.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';

class GifPage extends Equatable {
  const GifPage({
    required this.gifs,
    required this.totalCount,
    required this.count,
    required this.offset,
  });

  final List<Gif> gifs;
  final int totalCount;
  final int count;
  final int offset;

  bool get hasReachedMax =>
      gifs.isEmpty || offset + gifs.length >= totalCount;

  @override
  List<Object?> get props => [gifs, totalCount, count, offset];
}