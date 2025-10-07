import 'package:flutter_test/flutter_test.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_metadata.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_price.dart';
import 'package:web3_wallet_dashboard/utils/wallet_utils.dart';

void main() {
  final ethToken = TokenInformation(
    address: "0x123",
    network: "eth-mainnet",
    tokenAddress: null,
    tokenBalance: "0x025fa93c9f31b", // ~0.0413 ETH
    tokenMetadata: null,
    tokenPrices: [
      TokenPrice(
        currency: "usd",
        value: "2000.0",
        lastUpdatedAt: DateTime.now().toIso8601String(),
      )
    ],
  );

  final token = TokenInformation(
    address: "0x456",
    network: "eth-mainnet",
    tokenAddress: "0xABC",
    tokenBalance: "0x56bc75e2d63100000", // 100 tokens (18 decimals)
    tokenMetadata: TokenMetadata(
      symbol: "TKN",
      name: "MyToken",
      decimals: 18,
      logo: null,
    ),
    tokenPrices: [
      TokenPrice(
        currency: "usd",
        value: "1.25",
        lastUpdatedAt: DateTime.now().toIso8601String(),
      )
    ],
  );

  group('WalletUtils', () {
    test('isNativeToken returns true for native token', () {
      expect(WalletUtils.isNativeToken(ethToken), isTrue);
      expect(WalletUtils.isNativeToken(token), isFalse);
    });

    test('convertHexBalanceToDouble converts correctly', () {
      final value = WalletUtils.convertHexBalanceToDouble(token.tokenBalance, 18);
      expect(value, 100.0);
    });

    test('getFormattedBalance formats properly', () {
      final formatted = WalletUtils.getFormattedBalance(token, decimalPlaces: 2);
      expect(formatted, '100.00');
    });

    test('getFormattedBalance returns 0.0 for invalid hex', () {
      final brokenToken = token.copyWith(tokenBalance: 'invalid');
      final result = WalletUtils.getFormattedBalance(brokenToken);
      expect(result, '0.0');
    });

    test('getUSDPrice returns null when no prices', () {
      final noPriceToken = token.copyWith(tokenPrices: []);
      expect(WalletUtils.getUSDPrice(noPriceToken), isNull);
    });

    test('getUSDPrice returns correct price', () {
      expect(WalletUtils.getUSDPrice(token), 1.25);
    });

    test('calculateTokenUSDValue returns correct value', () {
      final usd = WalletUtils.calculateTokenUSDValue(token);
      expect(usd, 125.0); // 100 * 1.25
    });

    test('calculateTotalUSD sums correctly', () {
      final total = WalletUtils.calculateTotalUSD([token, token]);
      expect(total, 250.0);
    });

    test('formatUSD formats correctly with commas and decimals', () {
      expect(WalletUtils.formatUSD(1234567.891), '\$1,234,567.89');
      expect(WalletUtils.formatUSD(0.0), '\$0.00');
    });

    test('shortenAddress shortens long address', () {
      final short = WalletUtils.shortenAddress("0x86bBF3f5B7fd6bB206f0070fAcF88556aB905088");
      expect(short, "0x86bB...5088");
    });

    test('shortenAddress returns original if too short', () {
      expect(WalletUtils.shortenAddress("0x1234"), "0x1234");
    });

    test('getTokenSymbol returns correct symbol or fallback', () {
      expect(WalletUtils.getTokenSymbol(token), 'TKN');
      expect(WalletUtils.getTokenSymbol(ethToken), 'ETH');
    });

    test('getTokenName returns correct name or fallback', () {
      expect(WalletUtils.getTokenName(token), 'MyToken');
      expect(WalletUtils.getTokenName(ethToken), 'Ethereum');
    });

    test('convertHexBalanceToDouble returns 0.0 for bad input', () {
      final result = WalletUtils.convertHexBalanceToDouble("xyz", 18);
      expect(result, 0.0);
    });

    test('getUSDPrice returns null on bad price string', () {
      final badPriceToken = token.copyWith(tokenPrices: [
        TokenPrice(currency: 'usd', value: 'invalid', lastUpdatedAt: '')
      ]);
      expect(WalletUtils.getUSDPrice(badPriceToken), isNull);
    });
  });
}
