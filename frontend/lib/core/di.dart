import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth_repository.dart';
//import '../data/repositories/transaction_repository.dart';
import '../logic/blocs/auth/auth_bloc.dart';
//import '../logic/blocs/transactions/transactions_bloc.dart';
import 'api_client.dart';

class AppProviders {
  static Widget setup({required Widget child}) {
    return MultiProvider(
      providers: [
        // Core dependencies
        Provider<Dio>(create: (_) => Dio()),
        Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),

        // API client
        ProxyProvider2<Dio, FlutterSecureStorage, ApiClient>(
          update: (_, dio, storage, __) => ApiClient(dio: dio, secureStorage: storage),
        ),

        // Repositories
        ProxyProvider2<ApiClient, FlutterSecureStorage, AuthRepository>(
          update: (_, apiClient, storage, __) =>
              AuthRepository(apiClient: apiClient, secureStorage: storage),
        ),
        // ProxyProvider<ApiClient, TransactionRepository>(
        //   update: (_, apiClient, __) => TransactionRepository(apiClient: apiClient),
        // ),

        // Blocs
        ProxyProvider<AuthRepository, AuthBloc>(
          update: (_, authRepo, __) => AuthBloc(authRepository: authRepo),
          dispose: (_, bloc) => bloc.close(),
        ),
        // ProxyProvider<TransactionRepository, TransactionsBloc>(
        //   update: (_, txnRepo, __) => TransactionsBloc(transactionRepository: txnRepo),
        //   dispose: (_, bloc) => bloc.close(),
        // ),
      ],
      child: child,
    );
  }
}