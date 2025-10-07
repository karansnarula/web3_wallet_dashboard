import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';
import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_bloc.dart';
import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_event.dart';
import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_state.dart';
import 'package:web3_wallet_dashboard/utils/wallet_utils.dart';

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key});

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  late BalancesBloc _balancesBloc;

  @override
  void initState() {
    super.initState();
    _balancesBloc = BlocProvider.of<BalancesBloc>(context);
    _balancesBloc.add(FetchBalances());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Web3 Wallet Dashboard"),
        centerTitle: true,
      ),
      body: BlocBuilder<BalancesBloc, BalancesState>(
        builder: (context, state) {
          if (state is LoadingBalanceState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LoadedBalanceState) {
            return _buildContent(state.tokens);
          }

          if (state is ErrorState) {
            return _buildError(state.errorMessage);
          }

          return const Center(child: Text("Unknown state"));
        },
      ),
    );
  }

  Widget _buildContent(List<TokenInformation> tokens) {
    return RefreshIndicator(
      onRefresh: () async {
        _balancesBloc.add(FetchBalances(forceRefresh: true));
        // Wait for the new state
        await _balancesBloc.stream.firstWhere(
              (state) => state is! LoadingBalanceState,
        );
      },
      child: Column(
        children: [
          // Wallet Address Header
          _buildWalletHeader(),

          // Total Balance Card
          _buildTotalBalance(tokens),

          // Token List
          Expanded(
            child: _buildTokenList(tokens),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletHeader() {
    final shortAddress = WalletUtils.shortenAddress(
      BalancesBloc.walletAddress,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Wallet Address',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            shortAddress,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalance(List<TokenInformation> tokens) {
    final totalUSD = WalletUtils.calculateTotalUSD(tokens);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            WalletUtils.formatUSD(totalUSD),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenList(List<TokenInformation> tokens) {
    if (tokens.isEmpty) {
      return const Center(
        child: Text(
          "No tokens found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tokens.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey.shade300,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final token = tokens[index];
        return _buildTokenItem(token);
      },
    );
  }

  Widget _buildTokenItem(TokenInformation token) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Token Icon/Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade100,
            child: token.tokenMetadata?.logo != null
                ? ClipOval(
              child: Image.network(
                token.tokenMetadata!.logo!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildTokenInitial(token);
                },
              ),
            )
                : _buildTokenInitial(token),
          ),
          const SizedBox(width: 12),

          // Token Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WalletUtils.getTokenSymbol(token),
                  key: Key('token-symbol-${WalletUtils.getTokenSymbol(token)}'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  WalletUtils.getTokenName(token),
                  key: Key('token-name-${WalletUtils.getTokenName(token)}'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Balance Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                WalletUtils.getFormattedBalance(token),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                WalletUtils.formatUSD(
                  WalletUtils.calculateTokenUSDValue(token),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenInitial(TokenInformation token) {
    final symbol = WalletUtils.getTokenSymbol(token);
    return Text(
      symbol.isNotEmpty ? symbol[0] : '?',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildError(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _balancesBloc.add(FetchBalances(forceRefresh: true));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}