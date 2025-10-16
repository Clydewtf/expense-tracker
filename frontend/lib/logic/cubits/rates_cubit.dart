import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/rates_repository.dart';


class RatesState {
  final Map<String, double> rates;
  final bool loading;
  final String? error;

  RatesState({required this.rates, this.loading = false, this.error});

  RatesState copyWith({Map<String, double>? rates, bool? loading, String? error}) {
    return RatesState(
      rates: rates ?? this.rates,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class RatesCubit extends Cubit<RatesState> {
  final RatesRepository repository;

  RatesCubit({required this.repository}) : super(RatesState(rates: {}));

  Future<void> loadRates(String baseCurrency) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final rates = await repository.getAllRates(baseCurrency);
      emit(RatesState(rates: rates, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  double? convert(String from, String to, double amount) {
    if (from == to) return amount;
    
    final fromRate = state.rates[from];
    final toRate = state.rates[to];

    if (fromRate == null || toRate == null) return null;

    return amount * (toRate / fromRate);
  }
}