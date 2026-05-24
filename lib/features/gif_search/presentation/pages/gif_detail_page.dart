import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:giphy/core/widgets/loading_indicator.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';
import 'package:url_launcher/url_launcher.dart';

class GifDetailPage extends StatelessWidget {
  const GifDetailPage({required this.gif, super.key});

  final Gif gif;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(gif.title, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final image = _GifImage(gif: gif);
            final details = _GifDetails(gif: gif);

            if (orientation == Orientation.landscape) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Center(child: image)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: details,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  image,
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: details,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GifImage extends StatelessWidget {
  const _GifImage({required this.gif});

  final Gif gif;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'gif-${gif.id}',
      child: AspectRatio(
        aspectRatio: gif.aspectRatio,
        child: CachedNetworkImage(
          imageUrl: gif.fullUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const LoadingIndicator(),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
        ),
      ),
    );
  }
}

class _GifDetails extends StatelessWidget {
  const _GifDetails({required this.gif});

  final Gif gif;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(gif.title, style: theme.textTheme.titleLarge),
        if (gif.username != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text('@${gif.username}', style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
        if (gif.giphyUrl.isNotEmpty) ...[
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () => _openInGiphy(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open on Giphy'),
          ),
        ],
      ],
    );
  }

  Future<void> _openInGiphy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(gif.giphyUrl);

    var launched = false;
    if (uri != null) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Exception {
        launched = false;
      }
    }

    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the GIF in a browser.')),
      );
    }
  }
}
