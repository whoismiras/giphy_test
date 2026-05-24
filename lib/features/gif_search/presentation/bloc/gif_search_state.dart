import 'package:equatable/equatable.dart';
import 'package:giphy/core/error/failure.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';

enum GifSearchStatus { initial, loading, success, loadingMore, failure }

class GifSearchState extends Equatable {
  const GifSearchState({
    this.status = GifSearchStatus.initial,
    this.query = '',
    this.gifs = const [],
    this.hasReachedMax = false,
    this.failure,
    this.isOffline = false,
  });

  final GifSearchStatus status;
  final String query;
  final List<Gif> gifs;
  final bool hasReachedMax;
  final Failure? failure;
  final bool isOffline;

  bool get isTrending => query.isEmpty;

  bool get isInitialLoading =>
      status == GifSearchStatus.loading && gifs.isEmpty;

  bool get isFullScreenError =>
      status == GifSearchStatus.failure && gifs.isEmpty;

  bool get isEmptyResult =>
      status == GifSearchStatus.success && gifs.isEmpty;

  bool get isLoadingMore => status == GifSearchStatus.loadingMore;

  bool get hasPaginationError =>
      status == GifSearchStatus.failure && gifs.isNotEmpty;

  GifSearchState copyWith({
    GifSearchStatus? status,
    String? query,
    List<Gif>? gifs,
    bool? hasReachedMax,
    Failure? failure,
    bool clearFailure = false,
    bool? isOffline,
  }) {
    return GifSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      gifs: gifs ?? this.gifs,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      failure: clearFailure ? null : (failure ?? this.failure),
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    gifs,
    hasReachedMax,
    failure,
    isOffline,
  ];
}