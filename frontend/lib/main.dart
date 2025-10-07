import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'core/di.dart';
import 'core/app_router.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Регистрация адаптеров для моделей
  // Hive.registerAdapter(TransactionAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders.setup(
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}