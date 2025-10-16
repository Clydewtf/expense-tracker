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

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${txn.amount} ${txn.currency}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (txn.currency != defaultCurrency)
                  Text(
                    convertedAmount != null
                        ? '${convertedAmount.toStringAsFixed(2)} $defaultCurrency'
                        : 'Converting...',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            subtitle: Text(txn.description ?? ''),
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