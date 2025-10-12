import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/transaction/transaction_bloc.dart';
import '../../widgets/transaction_card.dart';


class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    context.read<TransactionsBloc>().add(LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(child: Text('No transactions yet.'));
            }
            final sortedTxns = List.of(state.transactions)
              ..sort((a, b) => b.date.compareTo(a.date));

            return ListView.builder(
              itemCount: sortedTxns.length,
              itemBuilder: (context, index) {
                final txn = sortedTxns[index];
                return InkWell(
                  child: TransactionCard(txn: txn),
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
            );
          } else if (state is TransactionsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}