import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:web3_wallet_dashboard/data/token/data_sources/remote/token_api.dart';
import 'package:web3_wallet_dashboard/data/token/models/request/address_information.dart';
import 'package:web3_wallet_dashboard/data/token/models/request/get_tokens_request.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/get_tokens_response.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_data.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_metadata.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_price.dart';
import 'package:web3_wallet_dashboard/data/token/repositories/token_repo.dart';
import 'package:web3_wallet_dashboard/data/utils/database/local_storage_manager.dart';
import 'package:web3_wallet_dashboard/data/utils/exceptions/api_exception.dart';

// Mock classes
class MockTokenApi extends Mock implements TokenApi {}
class MockLocalStorageManager extends Mock implements LocalStorageManager {}

void main() {
  late TokenRepoImpl repository;
  late MockTokenApi mockTokenApi;
  late MockLocalStorageManager mockLocalStorage;

  // Test data
  final testWalletAddress = '0x86bBF3f5B7fd6bB206f0070fAcF88556aB905088';
  final testAddresses = [
    AddressInformation(
      address: testWalletAddress,
      networks: ['eth-mainnet'],
    ),
  ];

  final testTokens = [
    TokenInformation(
      address: testWalletAddress,
      network: 'eth-mainnet',
      tokenAddress: null,
      tokenBalance: '0x0de0b6b3a7640000',
      tokenMetadata: TokenMetadata(
        symbol: null,
        decimals: 18,
        name: null,
        logo: null,
      ),
      tokenPrices: [
        TokenPrice(
          currency: 'usd',
          value: '2000.0',
          lastUpdatedAt: '2025-10-05T10:00:00Z',
        ),
      ],
    ),
    TokenInformation(
      address: testWalletAddress,
      network: 'eth-mainnet',
      tokenAddress: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
      tokenBalance: '0x3b9aca00',
      tokenMetadata: TokenMetadata(
        symbol: 'USDC',
        decimals: 6,
        name: 'USD Coin',
        logo: 'https://example.com/usdc.png',
      ),
      tokenPrices: [
        TokenPrice(
          currency: 'usd',
          value: '1.0',
          lastUpdatedAt: '2025-10-05T10:00:00Z',
        ),
      ],
    ),
  ];

  final testResponse = GetTokensResponse(
    data: TokenData(
      tokens: testTokens,
      pageKey: null,
    ),
  );

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(GetTokensRequest(addresses: testAddresses));
  });

  setUp(() {
    mockTokenApi = MockTokenApi();
    mockLocalStorage = MockLocalStorageManager();
    repository = TokenRepoImpl(
      tokenApi: mockTokenApi,
      localStorage: mockLocalStorage,
    );
  });

  group('TokenRepoImpl - getTokens', () {
    test('should return cached tokens when forceRefresh is false and cache exists', () async {
      // Arrange
      when(() => mockLocalStorage.getTokens(testWalletAddress))
          .thenAnswer((_) async => testTokens);

      // Act
      final result = await repository.getTokens(
        addresses: testAddresses,
        forceRefresh: false,
      );

      // Assert
      expect(result, testTokens);
      verify(() => mockLocalStorage.getTokens(testWalletAddress)).called(1);
      verifyNever(() => mockTokenApi.getTokensByAddress(any()));
    });

    test('should fetch from API when forceRefresh is false but cache is empty', () async {
      // Arrange
      when(() => mockLocalStorage.getTokens(testWalletAddress))
          .thenAnswer((_) async => null);
      when(() => mockTokenApi.getTokensByAddress(any()))
          .thenAnswer((_) async => testResponse);
      when(() => mockLocalStorage.saveTokens(
        walletAddress: any(named: 'walletAddress'),
        tokens: any(named: 'tokens'),
      )).thenAnswer((_) async => true);

      // Act
      final result = await repository.getTokens(
        addresses: testAddresses,
        forceRefresh: false,
      );

      // Assert
      expect(result, testTokens);
      verify(() => mockLocalStorage.getTokens(testWalletAddress)).called(1);
      verify(() => mockTokenApi.getTokensByAddress(any())).called(1);
      verify(() => mockLocalStorage.saveTokens(
        walletAddress: testWalletAddress,
        tokens: testTokens,
      )).called(1);
    });

    test('should fetch from API when forceRefresh is true (skip cache)', () async {
      // Arrange
      when(() => mockTokenApi.getTokensByAddress(any()))
          .thenAnswer((_) async => testResponse);
      when(() => mockLocalStorage.saveTokens(
        walletAddress: any(named: 'walletAddress'),
        tokens: any(named: 'tokens'),
      )).thenAnswer((_) async => true);

      // Act
      final result = await repository.getTokens(
        addresses: testAddresses,
        forceRefresh: true,
      );

      // Assert
      expect(result, testTokens);
      verifyNever(() => mockLocalStorage.getTokens(any()));
      verify(() => mockTokenApi.getTokensByAddress(any())).called(1);
      verify(() => mockLocalStorage.saveTokens(
        walletAddress: testWalletAddress,
        tokens: testTokens,
      )).called(1);
    });

    test('should save tokens to cache after successful API call', () async {
      // Arrange
      when(() => mockLocalStorage.getTokens(testWalletAddress))
          .thenAnswer((_) async => null);
      when(() => mockTokenApi.getTokensByAddress(any()))
          .thenAnswer((_) async => testResponse);
      when(() => mockLocalStorage.saveTokens(
        walletAddress: any(named: 'walletAddress'),
        tokens: any(named: 'tokens'),
      )).thenAnswer((_) async => true);

      // Act
      await repository.getTokens(
        addresses: testAddresses,
        forceRefresh: false,
      );

      // Assert
      verify(() => mockLocalStorage.saveTokens(
        walletAddress: testWalletAddress,
        tokens: testTokens,
      )).called(1);
    });

    test('should return cached tokens as fallback when API fails', () async {
      // Arrange
      var callCount = 0;
      when(() => mockLocalStorage.getTokens(testWalletAddress))
          .thenAnswer((_) async {
        callCount++;
        // First call returns null (no cache), second call returns cached tokens
        return callCount == 1 ? null : testTokens;
      });
      when(() => mockTokenApi.getTokensByAddress(any()))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act
      final result = await repository.getTokens(
        addresses: testAddresses,
        forceRefresh: false,
      );

      // Assert
      expect(result, testTokens);
      verify(() => mockTokenApi.getTokensByAddress(any())).called(1);
      verify(() => mockLocalStorage.getTokens(testWalletAddress)).called(2);
    });

    test('should throw ApiException when API fails and no cache exists', () async {
      // Arrange
      when(() => mockLocalStorage.getTokens(testWalletAddress))
          .thenAnswer((_) async => null);
      when(() => mockTokenApi.getTokensByAddress(any()))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act & Assert
      expect(
            () => repository.getTokens(
          addresses: testAddresses,
          forceRefresh: false,
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('should handle empty token list from API', () async {
      // Arrange
      final emptyResponse = GetTokensResponse(
        data: TokenData(tokens: [], pageKey: null),
      );
      when(() => mockLocalStorage.getTokens(testWalletAddress))
          .thenAnswer((_) async => null);
      when(() => mockTokenApi.getTokensByAddress(any()))
          .thenAnswer((_) async => emptyResponse);
      when(() => mockLocalStorage.saveTokens(
        walletAddress: any(named: 'walletAddress'),
        tokens: any(named: 'tokens'),
      )).thenAnswer((_) async => true);

      // Act
      final result = await repository.getTokens(
        addresses: testAddresses,
        forceRefresh: false,
      );

      // Assert
      expect(result, isEmpty);
      verify(() => mockLocalStorage.saveTokens(
        walletAddress: testWalletAddress,
        tokens: [],
      )).called(1);
    });
  });
}