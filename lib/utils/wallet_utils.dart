import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';

class WalletUtils {
  /// Check if token is native ETH (tokenAddress is null)
  static bool isNativeToken(TokenInformation token) {
    return token.tokenAddress == null;
  }

  /// Convert hex balance string to double with decimals
  /// Example: "0x000000000000000000000000000000000000000000000000000025fa93c9f31b" → 0.0043
  static double convertHexBalanceToDouble(String hexBalance, int decimals) {
    try {
      // Remove '0x' prefix if exists
      String hex = hexBalance.startsWith('0x')
          ? hexBalance.substring(2)
          : hexBalance;

      // Parse hex to BigInt
      final balance = BigInt.parse(hex, radix: 16);

      // Convert to double considering decimals
      final divisor = BigInt.from(10).pow(decimals);
      final result = balance / divisor;

      return result.toDouble();
    } catch (e) {
      print('Error converting hex balance: $e');
      return 0.0;
    }
  }

  /// Get formatted balance as string with specified decimal places
  /// Example: 0.004321 → "0.0043" (4 decimals)
  static String getFormattedBalance(
      TokenInformation token, {
        int decimalPlaces = 10,
      }) {
    final decimals = token.tokenMetadata?.decimals ?? 18;
    final balance = convertHexBalanceToDouble(token.tokenBalance, decimals);

    if (balance == 0.0) {
      return '0.0';
    }

    return balance.toStringAsFixed(decimalPlaces);
  }

  /// Get USD price for a token
  /// Returns null if price not available
  static double? getUSDPrice(TokenInformation token) {
    if (token.tokenPrices == null || token.tokenPrices!.isEmpty) {
      return null;
    }

    try {
      final priceStr = token.tokenPrices!.first.value;
      return double.parse(priceStr);
    } catch (e) {
      print('Error parsing USD price: $e');
      return null;
    }
  }

  /// Calculate USD value for a single token
  /// balance * price
  static double calculateTokenUSDValue(TokenInformation token) {
    final decimals = token.tokenMetadata?.decimals ?? 18;
    final balance = convertHexBalanceToDouble(token.tokenBalance, decimals);
    final price = getUSDPrice(token) ?? 0.0;

    return balance * price;
  }

  /// Calculate total USD value for all tokens
  static double calculateTotalUSD(List<TokenInformation> tokens) {
    double total = 0.0;

    for (var token in tokens) {
      total += calculateTokenUSDValue(token);
    }

    return total;
  }

  /// Format USD value as string with 2 decimal places
  /// Example: 1234.56789 → "$1,234.57"
  static String formatUSD(double value) {
    if (value == 0.0) {
      return '\$0.00';
    }

    // Format with commas and 2 decimal places
    return '\$${value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}';
  }

  /// Shorten wallet address
  /// Example: "0x86bBF3f5B7fd6bB206f0070fAcF88556aB905088" → "0x86bB...5088"
  static String shortenAddress(String address, {int startChars = 6, int endChars = 4}) {
    if (address.length <= startChars + endChars) {
      return address;
    }

    final start = address.substring(0, startChars);
    final end = address.substring(address.length - endChars);

    return '$start...$end';
  }

  /// Get token symbol or fallback
  /// Returns symbol or "Unknown" if not available
  static String getTokenSymbol(TokenInformation token) {
    if (isNativeToken(token)) {
      return 'ETH';
    }
    return token.tokenMetadata?.symbol ?? 'Unknown';
  }

  /// Get token name or fallback
  /// Returns name or "Unknown Token" if not available
  static String getTokenName(TokenInformation token) {
    if (isNativeToken(token)) {
      return 'Ethereum';
    }
    return token.tokenMetadata?.name ?? 'Unknown Token';
  }
}