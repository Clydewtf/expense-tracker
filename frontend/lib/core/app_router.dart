import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/profile_screen.dart';
import '../presentation/screens/transaction/add_transaction_screen.dart';
import '../presentation/screens/transaction/edit_transaction_screen.dart';
import '../presentation/screens/transaction/transaction_detail_screen.dart';
import '../presentation/screens/transaction/transactions_screen.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/transactions':
        return MaterialPageRoute(builder: (_) => const TransactionsScreen());
      case '/transaction_detail':
        final int transactionId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => TransactionDetailScreen(transactionId: transactionId),);
      case '/add_transaction':
        return MaterialPageRoute(builder: (_) => const AddTransactionScreen(),);
      case '/edit-transaction':
        final transaction = settings.arguments as TransactionModel;
        return MaterialPageRoute(
          builder: (_) => EditTransactionScreen(transaction: transaction),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}