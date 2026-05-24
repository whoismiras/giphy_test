import 'package:flutter/widgets.dart';
import 'package:giphy/app/navigation/app_routes.dart';
import 'package:giphy/features/gif_search/domain/entities/gif.dart';

class AppCoordinator {
  AppCoordinator(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorState get _navigator => navigatorKey.currentState!;

  Future<void> showGifDetail(Gif gif) {
    return _navigator.pushNamed<void>(AppRoutes.detail, arguments: gif);
  }

  void pop() => _navigator.pop();
}