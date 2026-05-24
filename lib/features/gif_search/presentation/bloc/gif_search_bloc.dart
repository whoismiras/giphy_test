import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giphy/core/config/app_config.dart';
import 'package:giphy/core/error/failure.dart';
import 'package:giphy/core/network/network_info.dart';
import 'package:giphy/features/gif_search/data/repositories/gif_repository.dart';
import 'package:giphy/features/gif_search/domain/entities/gif_page.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_event.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_state.dart';
import 'package:stream_transform/stream_transform.dart';

// Debounce the query events, then drop stale in-flight requests so only the
// last query wins.
EventTransformer<E> _debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(events.debounce(duration), mapper);
}

class GifSearchBloc extends Bloc<GifSearchEvent, GifSearchState> {
  GifSearchBloc({
    required GifRepository repository,
    required NetworkInfo networkInfo,
  }) : _repository = repository,
       _networkInfo = networkInfo,
       super(const GifSearchState()) {
    on<GifSearchStartedEvent>(_onStarted);
    on<GifQueryChangedEvent>(
      _onQueryChanged,
      transformer: _debounceRestartable(AppConfig.searchDebounce),
    );
    on<GifNextPageRequestedEvent>(
      _onNextPageRequested,
      transformer: droppable(),
    );
    on<GifSearchRetriedEvent>(_onRetried);
    on<GifConnectivityChangedEvent>(_onConnectivityChanged);

    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      (isConnected) => add(GifConnectivityChangedEvent(isConnected)),
    );
  }

  final GifRepository _repository;
  final NetworkInfo _networkInfo;
  late final StreamSubscription<bool> _connectivitySubscription;

  Future<void> _onStarted(
    GifSearchStartedEvent event,
    Emitter<GifSearchState> emit,
  ) => _loadFirstPage(state.query, emit);

  Future<void> _onQueryChanged(
    GifQueryChangedEvent event,
    Emitter<GifSearchState> emit,
  ) => _loadFirstPage(event.query.trim(), emit);

  Future<void> _onRetried(
    GifSearchRetriedEvent event,
    Emitter<GifSearchState> emit,
  ) => _loadFirstPage(state.query, emit);

  Future<void> _loadFirstPage(
    String query,
    Emitter<GifSearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GifSearchStatus.loading,
        query: query,
        gifs: const [],
        hasReachedMax: false,
        clearFailure: true,
      ),
    );

    try {
      final page = await _fetch(query, offset: 0);
      emit(
        state.copyWith(
          status: GifSearchStatus.success,
          gifs: page.gifs,
          hasReachedMax: page.hasReachedMax,
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(status: GifSearchStatus.failure, failure: failure));
    }
  }

  Future<void> _onNextPageRequested(
    GifNextPageRequestedEvent event,
    Emitter<GifSearchState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.gifs.isEmpty ||
        state.status == GifSearchStatus.loading ||
        state.status == GifSearchStatus.loadingMore) {
      return;
    }

    emit(
      state.copyWith(status: GifSearchStatus.loadingMore, clearFailure: true),
    );

    try {
      final page = await _fetch(state.query, offset: state.gifs.length);
      emit(
        state.copyWith(
          status: GifSearchStatus.success,
          gifs: [...state.gifs, ...page.gifs],
          hasReachedMax: page.hasReachedMax,
        ),
      );
    } on Failure catch (failure) {
      // Keep what's already on screen — the UI surfaces a retry footer.
      emit(state.copyWith(status: GifSearchStatus.failure, failure: failure));
    }
  }

  Future<void> _onConnectivityChanged(
    GifConnectivityChangedEvent event,
    Emitter<GifSearchState> emit,
  ) async {
    final wasOffline = state.isOffline;
    emit(state.copyWith(isOffline: !event.isConnected));

    if (wasOffline &&
        event.isConnected &&
        state.status == GifSearchStatus.failure) {
      add(const GifSearchRetriedEvent());
    }
  }

  Future<GifPage> _fetch(String query, {required int offset}) {
    return query.isEmpty
        ? _repository.getTrendingGifs(offset: offset, limit: AppConfig.pageSize)
        : _repository.searchGifs(
          query: query,
          offset: offset,
          limit: AppConfig.pageSize,
        );
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
