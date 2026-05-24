import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 18,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Text(
              'You are offline',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }
}