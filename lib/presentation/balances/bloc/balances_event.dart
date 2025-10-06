abstract class BalancesEvent {}

class FetchBalances extends BalancesEvent {
  final bool forceRefresh;

  FetchBalances({this.forceRefresh = false});
}