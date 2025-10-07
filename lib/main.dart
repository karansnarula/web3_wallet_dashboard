import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3_wallet_dashboard/presentation/balances/ui/balances_screen.dart';

import 'core/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Setup dependency injection
  await setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 Wallet Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => getIt<BalancesBloc>(),
        child: const BalancesScreen(),
      ),
    );
  }
}