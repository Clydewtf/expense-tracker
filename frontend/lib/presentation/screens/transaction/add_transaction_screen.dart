import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../../logic/blocs/transaction/transaction_bloc.dart';
import '../../../logic/blocs/user/user_bloc.dart';


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  String? selectedCurrency;

  final List<String> currencies = ['USD', 'EUR', 'RUB'];

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      selectedCurrency = userState.user.defaultCurrency;
    } else {
      selectedCurrency = 'USD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<TransactionsBloc, TransactionsState>(
          listener: (context, state) {
            if (state is TransactionsError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is TransactionsLoaded) {
              Navigator.pop(context);
            }
          },
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  items: currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCurrency = value),
                  decoration: const InputDecoration(labelText: 'Currency'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && selectedCurrency != null) {
                      FocusScope.of(context).unfocus();
                      final txn = TransactionModel(
                        amount: double.parse(_amountController.text),
                        category: _categoryController.text,
                        description: _descriptionController.text,
                        currency: selectedCurrency!,
                        date: DateTime.now(),
                      );
                      context.read<TransactionsBloc>().add(AddTransactionEvent(txn));
                    }
                  },
                  child: const Text('Add Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}