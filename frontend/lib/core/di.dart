import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../services/network_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/sources/local/local_transaction_source.dart';
import '../data/sources/remote/remote_transaction_source.dart';
import '../logic/blocs/auth/auth_bloc.dart';
import '../logic/blocs/transaction/transaction_bloc.dart';
import 'api_client.dart';


class AppProviders {
  static Future<Widget> setup({
    required Widget child,
    required LocalTransactionSource localSource,
  }) async {
    return MultiProvider(
      providers: [
        // Core dependencies
        Provider<Dio>(create: (_) => Dio()),
        Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),

        // Services
        ChangeNotifierProvider<NetworkService>(create: (_) => NetworkService()),

        // API client
        ProxyProvider2<Dio, FlutterSecureStorage, ApiClient>(
          update: (_, dio, storage, __) => ApiClient(dio: dio, secureStorage: storage),
        ),

        // Local source (already initialized)
        Provider<LocalTransactionSource>.value(value: localSource),

        // Remote source
        ProxyProvider<ApiClient, RemoteTransactionSource>(
          update: (_, apiClient, __) => RemoteTransactionSource(apiClient: apiClient),
        ),

        // Offline repository
        ProxyProvider3<LocalTransactionSource, RemoteTransactionSource, NetworkService, OfflineTransactionRepository>(
          update: (_, localSource, remoteSource, networkService, __) {
            final repo = OfflineTransactionRepository(
              localSource: localSource,
              remoteSource: remoteSource,
            );

            networkService.onReconnect = () async {
              await Future.delayed(const Duration(seconds: 3));
              await repo.syncTransactions();
            };

            return repo;
          },
        ),

        // Auth repository
        ProxyProvider2<ApiClient, FlutterSecureStorage, AuthRepository>(
          update: (_, apiClient, storage, __) =>
              AuthRepository(apiClient: apiClient, secureStorage: storage),
        ),

        // Blocs
        ProxyProvider<AuthRepository, AuthBloc>(
          update: (_, authRepo, __) => AuthBloc(authRepository: authRepo),
          dispose: (_, bloc) => bloc.close(),
        ),

        ProxyProvider2<OfflineTransactionRepository, AuthRepository, TransactionsBloc>(
          update: (_, txnRepo, authRepo, previous) => previous ?? 
              TransactionsBloc(transactionRepository: txnRepo, authRepository: authRepo),
          dispose: (_, bloc) => bloc.close(),
        ),
      ],
      child: child,
    );
  }
}