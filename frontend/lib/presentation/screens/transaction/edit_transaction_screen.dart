import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../../logic/blocs/transaction/transaction_bloc.dart';


class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _currencyController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _categoryController = TextEditingController(text: widget.transaction.category);
    _currencyController = TextEditingController(text: widget.transaction.currency);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _updateTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final updates = {
      'description': _descriptionController.text,
      'amount': double.tryParse(_amountController.text) ?? 0,
      'category': _categoryController.text,
      'currency': _currencyController.text,
    };

    context.read<TransactionsBloc>().add(
      UpdateTransactionEvent(widget.transaction.id!, updates),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionsBloc, TransactionsState>(
      listener: (context, state) {
        if (state is TransactionDetailLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction updated successfully!')),
          );
          Navigator.pop(context);
        } else if (state is TransactionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Transaction')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter amount' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter category' : null,
                ),
                TextFormField(
                  controller: _currencyController,
                  decoration: const InputDecoration(labelText: 'Currency'),
                ),
                const SizedBox(height: 20),
                BlocBuilder<TransactionsBloc, TransactionsState>(
                  builder: (context, state) {
                    final isLoading = state is TransactionsLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _updateTransaction,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Transaction'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}