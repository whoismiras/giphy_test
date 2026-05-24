import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:giphy/app/navigation/app_coordinator.dart';
import 'package:giphy/core/network/dio_client.dart';
import 'package:giphy/core/network/network_info.dart';
import 'package:giphy/features/gif_search/data/datasources/giphy_remote_data_source.dart';
import 'package:giphy/features/gif_search/data/repositories/gif_repository.dart';
import 'package:giphy/features/gif_search/presentation/bloc/gif_search_bloc.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt
    ..registerLazySingleton<Dio>(() => DioClient().dio)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<GlobalKey<NavigatorState>>(
      GlobalKey<NavigatorState>.new,
    )
    ..registerLazySingleton<AppCoordinator>(() => AppCoordinator(getIt()))
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()))
    ..registerLazySingleton<GiphyRemoteDataSource>(
      () => GiphyRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<GifRepository>(
      () => GifRepository(
        remoteDataSource: getIt(),
        networkInfo: getIt(),
      ),
    )
    ..registerFactory<GifSearchBloc>(
      () => GifSearchBloc(
        repository: getIt(),
        networkInfo: getIt(),
      ),
    );
}