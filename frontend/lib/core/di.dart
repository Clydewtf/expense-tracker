import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../logic/blocs/auth/auth_bloc.dart';
import '../logic/blocs/transactions/transactions_bloc.dart';
import '../services/api_client.dart';

class AppProviders {
  static Widget setup({required Widget child}) {
    return MultiProvider(
      providers: [
        // Services
        Provider<ApiClient>(
          create: (_) => ApiClient(baseUrl: 'http://localhost:8000'),
        ),

        // Repositories
        ProxyProvider<ApiClient, AuthRepository>(
          update: (_, apiClient, __) => AuthRepository(apiClient: apiClient),
        ),
        ProxyProvider<ApiClient, TransactionRepository>(
          update: (_, apiClient, __) => TransactionRepository(apiClient: apiClient),
        ),

        // Blocs
        ProxyProvider<AuthRepository, AuthBloc>(
          update: (_, authRepo, __) => AuthBloc(authRepository: authRepo),
          dispose: (_, bloc) => bloc.close(),
        ),
        ProxyProvider<TransactionRepository, TransactionsBloc>(
          update: (_, txnRepo, __) => TransactionsBloc(transactionRepository: txnRepo),
          dispose: (_, bloc) => bloc.close(),
        ),
      ],
      child: child,
    );
  }
}