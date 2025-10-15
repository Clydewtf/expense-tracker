import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'core/di.dart';
import 'core/app_router.dart';
import 'data/sources/local/hive_transaction.dart';
import 'data/sources/local/local_transaction_source.dart';
import 'presentation/widgets/network_banner.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HiveTransactionAdapter());

  final localSource = LocalTransactionSource();
  await localSource.init();

  runApp(
    await AppProviders.setup(
      localSource: localSource,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',

      builder: (context, child) {
        return NetworkBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}