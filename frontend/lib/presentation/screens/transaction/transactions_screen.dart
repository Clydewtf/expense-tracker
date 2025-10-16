import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/transaction/transaction_bloc.dart';
import '../../../logic/blocs/user/user_bloc.dart';
import '../../../logic/cubits/rates_cubit.dart';
import '../../../services/network_service.dart';
import '../../widgets/transaction_card.dart';


class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late NetworkService _networkService;

  @override
  void initState() {
    super.initState();
    _networkService = context.read<NetworkService>();

    _loadTransactions();
    _loadRates();

    _networkService.addListener(_onNetworkChange);
  }

  void _onNetworkChange() {
    if (_networkService.isOnline) {
      _loadTransactions();
      _loadRates();
    }
  }

  void _loadTransactions() {
    context.read<TransactionsBloc>().add(LoadTransactions());
  }

  void _loadRates() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<RatesCubit>().loadRates(userState.user.defaultCurrency);
    }
  }

  @override
  void dispose() {
    _networkService.removeListener(_onNetworkChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          String defaultCurrency = 'USD';
          if (userState is UserLoaded) {
            defaultCurrency = userState.user.defaultCurrency;
          }

          return BlocConsumer<TransactionsBloc, TransactionsState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is TransactionsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TransactionsLoaded) {
                final txns = state.transactions;
                if (txns.isEmpty) {
                  return const Center(child: Text('No transactions yet.'));
                }

                final sortedTxns = List.of(txns)
                  ..sort((a, b) => b.date.compareTo(a.date));

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadTransactions();
                    _loadRates();
                  },
                  child: ListView.builder(
                    itemCount: sortedTxns.length,
                    itemBuilder: (context, index) {
                      final txn = sortedTxns[index];
                      return InkWell(
                        child: TransactionCard(
                          txn: txn,
                          defaultCurrency: defaultCurrency,
                        ),
                        onTap: () async {
                          final txnId = txn.id ?? txn.localKey;
                          if (txnId == null) return;

                          await Navigator.pushNamed(
                            context,
                            '/transaction_detail',
                            arguments: txnId,
                          );
                          if (!mounted) return;
                          _loadTransactions();
                        },
                      );
                    },
                  ),
                );
              } else if (state is TransactionsError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }
}