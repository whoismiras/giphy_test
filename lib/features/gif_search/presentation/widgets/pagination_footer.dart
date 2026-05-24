import 'package:flutter/material.dart';
import 'package:giphy/core/widgets/loading_indicator.dart';

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    required this.isLoadingMore,
    required this.hasError,
    required this.onRetry,
    super.key,
  });

  final bool isLoadingMore;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: LoadingIndicator(),
      );
    }
    if (hasError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Couldn't load more — retry"),
          ),
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}
