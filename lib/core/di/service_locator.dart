import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:web3_wallet_dashboard/data/token/data_sources/remote/token_api.dart';
import 'package:web3_wallet_dashboard/data/token/repositories/token_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/utils/database/local_storage_manager.dart';
import '../../presentation/balances/bloc/balances_bloc.dart';

final getIt = GetIt.instance;

Future setupLocator() async {
  await registerNetworkComponent();
  await registerRepository();
  await registerLocalDB();
  await registerBloc();
}

Future registerNetworkComponent() async {
  final apiKey = dotenv.env['ALCHEMY_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('Missing ALCHEMY_API_KEY in .env');
  }
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.g.alchemy.com/data/v1/$apiKey/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ),
  );
  getIt.registerSingleton<TokenApi>(
    TokenApi(dio, baseUrl: dio.options.baseUrl),
  );
}

Future registerRepository() async {
  getIt.registerLazySingleton<TokenRepo>(
    () => TokenRepoImpl(
      tokenApi: getIt<TokenApi>(),
      localStorage: getIt<LocalStorageManager>(),
    ),
  );
}

Future registerLocalDB() async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Register LocalStorageManager
  getIt.registerSingleton<LocalStorageManager>(LocalStorageManager(prefs));
}

Future registerBloc() async {
  getIt.registerFactory<BalancesBloc>(
        () => BalancesBloc(tokenRepo: getIt<TokenRepo>()),
  );
}
