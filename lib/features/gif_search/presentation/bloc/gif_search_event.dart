import 'package:equatable/equatable.dart';

sealed class GifSearchEvent extends Equatable {
  const GifSearchEvent();

  @override
  List<Object?> get props => const [];
}

final class GifSearchStartedEvent extends GifSearchEvent {
  const GifSearchStartedEvent();
}

final class GifQueryChangedEvent extends GifSearchEvent {
  const GifQueryChangedEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class GifNextPageRequestedEvent extends GifSearchEvent {
  const GifNextPageRequestedEvent();
}

final class GifSearchRetriedEvent extends GifSearchEvent {
  const GifSearchRetriedEvent();
}

final class GifConnectivityChangedEvent extends GifSearchEvent {
  const GifConnectivityChangedEvent(this.isConnected);

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}
