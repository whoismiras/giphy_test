import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';

class GifGridItem extends StatelessWidget {
  const GifGridItem({required this.gif, required this.onTap, super.key});

  final Gif gif;
  final ValueChanged<Gif> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        child: InkWell(
          onTap: () => onTap(gif),
          child: AspectRatio(
            aspectRatio: gif.aspectRatio,
            child: Hero(
              tag: 'gif-${gif.id}',
              child: CachedNetworkImage(
                imageUrl: gif.previewUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) =>
                    ColoredBox(color: colorScheme.surfaceContainerHighest),
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
