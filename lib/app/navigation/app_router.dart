import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giphy/app/di/injection.dart';
import 'package:giphy/app/navigation/app_coordinator.dart';
import 'package:giphy/app/navigation/app_routes.dart';
import 'package:giphy/core/config/app_config.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_bloc.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_event.dart';
import 'package:giphy/features/gif_search/presentation/pages/gif_detail_page.dart';
import 'package:giphy/features/gif_search/presentation/pages/gif_search_page.dart';
import 'package:giphy/features/gif_search/presentation/pages/missing_api_key_page.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.search:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) {
            if (!AppConfig.hasApiKey) return const MissingApiKeyPage();
            return BlocProvider<GifSearchBloc>(
              create:
                  (_) =>
                      getIt<GifSearchBloc>()
                        ..add(const GifSearchStartedEvent()),
              child: GifSearchPage(
                onGifTap: getIt<AppCoordinator>().showGifDetail,
              ),
            );
          },
        );

      case AppRoutes.detail:
        final arg = settings.arguments;
        if (arg is! Gif) {
          return _errorRoute(settings, 'A GIF argument is required.');
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => GifDetailPage(gif: arg),
        );

      default:
        return _errorRoute(settings, 'Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(message)),
          ),
    );
  }
}
