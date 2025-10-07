import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';

class LocalStorageManager {
  static const String _cachedTokensKey = 'cached_tokens';

  final SharedPreferences _prefs;

  LocalStorageManager(this._prefs);

  /// Save tokens for a wallet
  Future<bool> saveTokens({
    required String walletAddress,
    required List<TokenInformation> tokens,
  }) async {
    final data = {
      'walletAddress': walletAddress,
      'tokens': tokens.map((t) => t.toJson()).toList(),
      'cachedAt': DateTime.now().toIso8601String(),
    };

    final jsonString = jsonEncode(data);
    return await _prefs.setString(_cachedTokensKey, jsonString);
  }

  /// Get cached tokens
  Future<List<TokenInformation>?> getTokens(String walletAddress) async {
    final jsonString = _prefs.getString(_cachedTokensKey);
    if (jsonString == null) return null;

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Verify wallet address matches
      if (data['walletAddress'] != walletAddress) return null;

      final List tokensList = data['tokens'] as List;
      return tokensList
          .map((t) => TokenInformation.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing cached tokens: $e');
      return null;
    }
  }
}