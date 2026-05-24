import 'package:flutter/material.dart';

class MissingApiKeyPage extends StatelessWidget {
  const MissingApiKeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Giphy Search')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.key_off_outlined,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Giphy API key required',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Paste the key into _fallbackApiKey in\n'
                'lib/core/config/app_config.dart\n\n'
                'or pass it via:\n'
                'flutter run --dart-define-from-file=env.json',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
