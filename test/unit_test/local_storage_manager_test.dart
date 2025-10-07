import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_metadata.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_price.dart';
import 'package:web3_wallet_dashboard/data/utils/database/local_storage_manager.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late LocalStorageManager localStorage;

  const walletAddress = '0x123';

  final testToken = TokenInformation(
    address: walletAddress,
    network: 'eth-mainnet',
    tokenAddress: '0xTokenAddress',
    tokenBalance: '0x01',
    tokenMetadata: TokenMetadata(
      symbol: 'TST',
      decimals: 18,
      name: 'Test Token',
      logo: null,
    ),
    tokenPrices: [
      TokenPrice(
        currency: 'usd',
        value: '1.00',
        lastUpdatedAt: DateTime.now().toIso8601String(),
      ),
    ],
  );

  setUp(() {
    mockPrefs = MockSharedPreferences();
    localStorage = LocalStorageManager(mockPrefs);
  });

  test('✅ saveTokens stores tokens in SharedPreferences', () async {
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

    final result = await localStorage.saveTokens(
      walletAddress: walletAddress,
      tokens: [testToken],
    );

    expect(result, isTrue);
    verify(() => mockPrefs.setString(
      'cached_tokens',
      any(that: contains('"walletAddress":"$walletAddress"')),
    )).called(1);
  });

  test('✅ getTokens returns tokens if wallet address matches', () async {
    final mockJson = jsonEncode({
      'walletAddress': walletAddress,
      'tokens': [testToken.toJson()],
      'cachedAt': DateTime.now().toIso8601String(),
    });

    when(() => mockPrefs.getString('cached_tokens')).thenReturn(mockJson);

    final result = await localStorage.getTokens(walletAddress);

    expect(result, isNotNull);
    expect(result!.length, 1);
    expect(result.first.tokenMetadata?.symbol, 'TST');
  });

  test('🟡 getTokens returns null if SharedPreferences has no value', () async {
    when(() => mockPrefs.getString('cached_tokens')).thenReturn(null);

    final result = await localStorage.getTokens(walletAddress);

    expect(result, isNull);
  });

  test('🛑 getTokens returns null if wallet address does not match', () async {
    final mockJson = jsonEncode({
      'walletAddress': '0xABC', // mismatched address
      'tokens': [testToken.toJson()],
      'cachedAt': DateTime.now().toIso8601String(),
    });

    when(() => mockPrefs.getString('cached_tokens')).thenReturn(mockJson);

    final result = await localStorage.getTokens(walletAddress);

    expect(result, isNull);
  });
}
