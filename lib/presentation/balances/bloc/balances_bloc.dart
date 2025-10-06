import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3_wallet_dashboard/core/contants/wallet_address.dart';
import 'package:web3_wallet_dashboard/data/token/models/request/address_information.dart';
import 'package:web3_wallet_dashboard/data/token/repositories/token_repo.dart';
import 'package:web3_wallet_dashboard/data/utils/exceptions/api_exception.dart';
import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_event.dart';
import 'package:web3_wallet_dashboard/presentation/balances/bloc/balances_state.dart';

class BalancesBloc extends Bloc<BalancesEvent, BalancesState> {
  final TokenRepo tokenRepo;
  static const String walletAddress = Wallet.walletAddress;

  BalancesBloc({required this.tokenRepo}) : super(InitBalanceState()) {
    on<FetchBalances>((event, emit) async {
      emit(LoadingBalanceState());
      await _fetchBalance(emit, forceRefresh: event.forceRefresh);
    });
  }

  Future<void> _fetchBalance(
    Emitter<BalancesState> emit, {
    bool forceRefresh = false,
  }) async {
    try {
      final addressInformation = AddressInformation(
        address: walletAddress,
        networks: ["eth-mainnet"],
      );

      final tokens = await tokenRepo.getTokens(
        addresses: [addressInformation],
        forceRefresh: forceRefresh,
      );

      emit(LoadedBalanceState(tokens));
    } on ApiException catch (e) {
      emit(ErrorState(e.message));
    } catch (e) {
      emit(ErrorState("Something went wrong, please try again later."));
    }
  }
}
