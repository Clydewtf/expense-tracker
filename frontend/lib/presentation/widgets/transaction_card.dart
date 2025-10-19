import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../logic/cubits/rates_cubit.dart';


class TransactionCard extends StatelessWidget {
  final TransactionModel txn;
  final String defaultCurrency;

  const TransactionCard({
    super.key,
    required this.txn,
    required this.defaultCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatesCubit, RatesState>(
      builder: (context, ratesState) {
        double? convertedAmount;
        if (ratesState.rates.isNotEmpty) {
          convertedAmount = (txn.currency == defaultCurrency)
              ? txn.amount
              : context.read<RatesCubit>().convert(txn.currency, defaultCurrency, txn.amount);
        }

        final isExpense = txn.type == 'expense';
        final icon = isExpense ? Icons.arrow_upward : Icons.arrow_downward;
        final iconColor = isExpense ? Colors.red : Colors.green;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.2),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              '${txn.amount.toStringAsFixed(2)} ${txn.currency}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (txn.currency != defaultCurrency)
                  Text(
                    convertedAmount != null
                        ? '${convertedAmount.toStringAsFixed(2)} $defaultCurrency'
                        : 'Converting...',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (txn.description != null && txn.description!.isNotEmpty)
                  Text(txn.description!, style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Text(
              '${txn.date.toLocal()}'.split(' ')[0],
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}