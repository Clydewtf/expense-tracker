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
  String selectedType = 'expense';

  final List<String> currencies = ['USD', 'EUR', 'RUB'];
  final List<Map<String, dynamic>> types = [
    {'label': 'Expense', 'value': 'expense', 'icon': Icons.arrow_upward, 'color': Colors.red},
    {'label': 'Income', 'value': 'income', 'icon': Icons.arrow_downward, 'color': Colors.green},
  ];

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
            child: ListView(
              children: [
                Text(
                  'Transaction type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: types.map((type) {
                    final isSelected = selectedType == type['value'];
                    return ChoiceChip(
                      label: Row(
                        children: [
                          Icon(type['icon'], color: isSelected ? Colors.white : type['color']),
                          const SizedBox(width: 6),
                          Text(type['label']),
                        ],
                      ),
                      selectedColor: type['color'],
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => selectedType = type['value']);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter amount' : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter category' : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  items: currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCurrency = value),
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Add Transaction'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        selectedCurrency != null) {
                      FocusScope.of(context).unfocus();

                      final txn = TransactionModel(
                        amount: double.parse(_amountController.text),
                        category: _categoryController.text,
                        description: _descriptionController.text,
                        currency: selectedCurrency!,
                        date: DateTime.now(),
                        type: selectedType,
                      );

                      context
                          .read<TransactionsBloc>()
                          .add(AddTransactionEvent(txn));
                    }
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