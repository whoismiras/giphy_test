import 'package:flutter/widgets.dart';
import 'package:giphy/app/app.dart';
import 'package:giphy/app/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const GiphyApp());
}
