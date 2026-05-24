import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:giphy/core/error/failure.dart';
import 'package:giphy/core/widgets/error_view.dart';
import 'package:giphy/core/widgets/loading_indicator.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_bloc.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_event.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_state.dart';
import 'package:giphy/features/gif_search/presentation/widgets/gif_grid_item.dart';
import 'package:giphy/features/gif_search/presentation/widgets/gif_search_field.dart';
import 'package:giphy/features/gif_search/presentation/widgets/offline_banner.dart';
import 'package:giphy/features/gif_search/presentation/widgets/pagination_footer.dart';

class GifSearchPage extends StatelessWidget {
  const GifSearchPage({required this.onGifTap, super.key});

  final ValueChanged<Gif> onGifTap;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GifSearchBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giphy Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GifSearchField(
              onChanged: (query) => bloc.add(GifQueryChangedEvent(query)),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          BlocSelector<GifSearchBloc, GifSearchState, bool>(
            selector: (state) => state.isOffline,
            builder:
                (context, isOffline) =>
                    isOffline ? const OfflineBanner() : const SizedBox.shrink(),
          ),
          Expanded(child: _GifResultsView(onGifTap: onGifTap)),
        ],
      ),
    );
  }
}

class _GifResultsView extends StatefulWidget {
  const _GifResultsView({required this.onGifTap});

  final ValueChanged<Gif> onGifTap;

  @override
  State<_GifResultsView> createState() => _GifResultsViewState();
}

class _GifResultsViewState extends State<_GifResultsView> {
  final ScrollController _scrollController = ScrollController();

  static const double _loadMoreThreshold = 400;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<GifSearchBloc>().add(const GifNextPageRequestedEvent());
    }
  }

  Future<void> _onRefresh() async {
    final bloc =
        context.read<GifSearchBloc>()..add(const GifSearchRetriedEvent());
    await bloc.stream.firstWhere(
      (state) => state.status != GifSearchStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GifSearchBloc, GifSearchState>(
      listenWhen:
          (previous, current) =>
              previous.status != current.status && current.hasPaginationError,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                state.failure?.message ?? 'Failed to load more GIFs.',
              ),
            ),
          );
      },
      builder: (context, state) {
        if (state.isInitialLoading) return const LoadingIndicator();

        if (state.isFullScreenError) {
          return ErrorView(
            message: state.failure?.message ?? 'Something went wrong.',
            icon: _iconForFailure(state.failure),
            onRetry:
                () => context.read<GifSearchBloc>().add(
                  const GifSearchRetriedEvent(),
                ),
          );
        }

        if (state.isEmptyResult) return _EmptyResultView(query: state.query);

        return RefreshIndicator.adaptive(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverMasonryGrid.extent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: state.gifs.length,
                  itemBuilder:
                      (context, index) => GifGridItem(
                        gif: state.gifs[index],
                        onTap: widget.onGifTap,
                      ),
                ),
              ),
              SliverToBoxAdapter(
                child: PaginationFooter(
                  isLoadingMore: state.isLoadingMore,
                  hasError: state.hasPaginationError,
                  onRetry:
                      () => context.read<GifSearchBloc>().add(
                        const GifNextPageRequestedEvent(),
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForFailure(Failure? failure) {
    return switch (failure) {
      NetworkFailure() => Icons.wifi_off,
      TimeoutFailure() => Icons.timer_off_outlined,
      _ => Icons.error_outline,
    };
  }
}

class _EmptyResultView extends StatelessWidget {
  const _EmptyResultView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No GIFs found for "$query"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
