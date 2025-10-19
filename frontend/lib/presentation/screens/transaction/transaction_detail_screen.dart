import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/transaction/transaction_bloc.dart';
import '../../../logic/blocs/user/user_bloc.dart';
import '../../../logic/cubits/rates_cubit.dart';


class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionsBloc>().add(LoadTransactionById(widget.transactionId));
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    String? defaultCurrency;
    if (userState is UserLoaded) {
      defaultCurrency = userState.user.defaultCurrency;
    }

    final ratesCubit = context.watch<RatesCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final state = context.read<TransactionsBloc>().state;
              if (state is TransactionDetailLoaded) {
                Navigator.pushNamed(
                  context,
                  '/edit-transaction',
                  arguments: state.transaction,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm delete'),
                  content: const Text('Are you sure you want to delete this transaction?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (!mounted) return;
              if (confirmed ?? false) {
                context.read<TransactionsBloc>().add(DeleteTransactionEvent(id: widget.transactionId));
              }
            },
          ),
        ],
      ),
      body: BlocListener<TransactionsBloc, TransactionsState>(
        listener: (context, state) {
          if (state is TransactionDeleted) {
            Navigator.pop(context, true);
          } else if (state is TransactionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<TransactionsBloc, TransactionsState>(
          builder: (context, state) {
            if (state is TransactionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionDetailLoaded) {
              final txn = state.transaction;
              final dateOnly = txn.date.toLocal().toString().split(' ')[0];
              double? convertedAmount;
              if (defaultCurrency != null) {
                convertedAmount = ratesCubit.convert(txn.currency, defaultCurrency, txn.amount);
              }

              final isExpense = txn.type == 'expense';
              final typeColor = isExpense ? Colors.red : Colors.green;
              final typeLabel = isExpense ? 'Expense' : 'Income';
              final typeIcon = isExpense ? Icons.arrow_upward : Icons.arrow_downward;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(typeIcon, color: typeColor),
                        const SizedBox(width: 8),
                        Text(
                          typeLabel,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: typeColor),
                        ),
                        const Spacer(),
                        Icon(
                          txn.isSynced ? Icons.check_circle : Icons.sync_problem,
                          color: txn.isSynced ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Amount: ${txn.amount.toStringAsFixed(2)} ${txn.currency}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (defaultCurrency != null && txn.currency != defaultCurrency)
                      Text(
                        convertedAmount != null
                            ? '${convertedAmount.toStringAsFixed(2)} $defaultCurrency'
                            : 'Converting...',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    const SizedBox(height: 16),
                    Text('Category: ${txn.category}'),
                    const SizedBox(height: 8),
                    if (txn.description != null && txn.description!.isNotEmpty)
                      Text('Description: ${txn.description}'),
                    const SizedBox(height: 8),
                    Text('Date: $dateOnly'),
                  ],
                ),
              );
            } else if (state is TransactionsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}