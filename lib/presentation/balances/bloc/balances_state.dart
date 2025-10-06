import 'package:equatable/equatable.dart';
import 'package:web3_wallet_dashboard/data/token/models/response/token_information.dart';

abstract class BalancesState extends Equatable {}

class InitBalanceState extends BalancesState {
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class LoadingBalanceState extends BalancesState {
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class LoadedBalanceState extends BalancesState {
  List<TokenInformation> tokens;
  LoadedBalanceState(this.tokens);
  @override
  // TODO: implement props
  List<Object?> get props => [tokens];

}

class ErrorState extends BalancesState {
  String errorMessage;
  ErrorState(this.errorMessage);
  @override
  // TODO: implement props
  List<Object?> get props => [errorMessage];

}