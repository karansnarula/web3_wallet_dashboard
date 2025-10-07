import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_bloc.dart';
import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_state.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_metadata.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_price.dart';
import 'package:web3_wallet_dashboard/presentation/balances/ui/balances_screen.dart';

class MockBalancesBloc extends Mock implements BalancesBloc {}

void main() {
  late MockBalancesBloc mockBloc;

  setUp(() {
    mockBloc = MockBalancesBloc();
    when(() => mockBloc.state).thenReturn(LoadingBalanceState());
    when(() => mockBloc.stream)
        .thenAnswer((_) => Stream.value(LoadingBalanceState()));
  });

  Widget buildTestableWidget(BalancesBloc bloc) {
    return MaterialApp(
      home: BlocProvider<BalancesBloc>.value(
        value: bloc,
        child: const BalancesScreen(),
      ),
    );
  }

  testWidgets('🌀 Shows loading indicator in LoadingBalanceState', (tester) async {
    when(() => mockBloc.state).thenReturn(LoadingBalanceState());

    await tester.pumpWidget(buildTestableWidget(mockBloc));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('✅ Shows token list in LoadedBalanceState', (tester) async {
    final tokens = [
      TokenInformation(
        address: "0x...",
        network: "eth-mainnet",
        tokenAddress: "0xgravity",
        tokenBalance: "0x048a846dc9386400", // 5.2 tokens (assuming 18 decimals)
        tokenMetadata: TokenMetadata(
          symbol: "G",
          name: "Gravity",
          decimals: 18,
          logo: null,
        ),
        tokenPrices: [
          TokenPrice(
            currency: "usd",
            value: "0.0103856037",
            lastUpdatedAt: DateTime.now().toIso8601String(),
          )
        ],
      ),
      TokenInformation(
        address: "0x...",
        network: "eth-mainnet",
        tokenAddress: "0xusdc",
        tokenBalance: "0x0000000000000000000000000000000000000000000000000000000000000000", // 0
        tokenMetadata: TokenMetadata(
          symbol: "USDC",
          name: "USDC",
          decimals: 6,
          logo: null,
        ),
        tokenPrices: [
          TokenPrice(
            currency: "usd",
            value: "0.9996",
            lastUpdatedAt: DateTime.now().toIso8601String(),
          )
        ],
      ),
    ];

    when(() => mockBloc.state).thenReturn(LoadedBalanceState(tokens));

    await tester.pumpWidget(buildTestableWidget(mockBloc));

    // Wallet header visible
    expect(find.byKey(const Key('token-symbol-G')), findsOneWidget);
    expect(find.byKey(const Key('token-name-Gravity')), findsOneWidget);

    // USDC token
    expect(find.byKey(const Key('token-symbol-USDC')), findsOneWidget);// Symbol and Name
    expect(find.byKey(const Key('token-name-USDC')), findsOneWidget);
  });

  testWidgets('❌ Shows error message in ErrorState', (tester) async {
    const errorMessage = 'Something went wrong!';

    when(() => mockBloc.state).thenReturn(ErrorState(errorMessage));
    when(() => mockBloc.stream)
        .thenAnswer((_) => Stream.value(ErrorState(errorMessage)));
    await tester.pumpWidget(buildTestableWidget(mockBloc));
    await tester.pumpAndSettle(); // <--- Important
    expect(find.text('Error'), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
