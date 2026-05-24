import 'package:flutter/material.dart';
import 'package:giphy/app/di/injection.dart';
import 'package:giphy/app/navigation/app_coordinator.dart';
import 'package:giphy/app/navigation/app_router.dart';
import 'package:giphy/app/navigation/app_routes.dart';
import 'package:giphy/core/theme/app_theme.dart';

class GiphyApp extends StatelessWidget {
  const GiphyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final coordinator = getIt<AppCoordinator>();
    return MaterialApp(
      title: 'Giphy Search',
      debugShowCheckedModeBanner: false,
      navigatorKey: coordinator.navigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      initialRoute: AppRoutes.search,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}