import 'package:dio/dio.dart';
import 'package:web3_wallet_dashboard/data/utils/exceptions/api_exception.dart';

import '../../utils/database/local_storage_manager.dart';
import '../data_sources/remote/token_api.dart';
import '../models/request/address_information.dart';
import '../models/request/get_tokens_request.dart';
import '../models/response/token_information.dart';

abstract class TokenRepo {
  Future<List<TokenInformation>> getTokens({
    required List<AddressInformation> addresses,
    bool forceRefresh = false,
  });
}

class TokenRepoImpl implements TokenRepo {
  final TokenApi tokenApi;
  final LocalStorageManager localStorage;

  TokenRepoImpl({
    required this.tokenApi,
    required this.localStorage,
  });

  @override
  Future<List<TokenInformation>> getTokens({
    required List<AddressInformation> addresses,
    bool forceRefresh = false,
  }) async {
    final walletAddress = addresses.first.address;

    // Try cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedTokens = await localStorage.getTokens(walletAddress);
      if (cachedTokens != null && cachedTokens.isNotEmpty) {
        return cachedTokens;
      }
    }

    // Fetch from API
    try {
      final request = GetTokensRequest(addresses: addresses);
      final response = await tokenApi.getTokensByAddress(request);
      final tokens = response.data.tokens;

      // Save to cache using wallet address as key
      await localStorage.saveTokens(
        walletAddress: walletAddress,
        tokens: tokens,
      );

      return tokens;
    } on DioException catch (e) {
      // Fallback to cache if API fails
      final cachedTokens = await localStorage.getTokens(walletAddress);
      if (cachedTokens != null && cachedTokens.isNotEmpty) {
        return cachedTokens;
      }

      throw ApiException(e.toString());
    }
  }
}


