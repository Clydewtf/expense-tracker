import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';


class TransactionCard extends StatelessWidget {
  final TransactionModel txn;

  const TransactionCard({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text('${txn.category} - ${txn.amount} ${txn.currency}'),
        subtitle: Text(txn.description ?? ''),
        trailing: Text(
          '${txn.date.toLocal()}'.split(' ')[0],
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}