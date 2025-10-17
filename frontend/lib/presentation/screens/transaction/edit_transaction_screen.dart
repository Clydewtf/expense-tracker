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

  String? selectedCurrency;
  late String selectedType;
  String? selectedCategory;

  final List<String> currencies = ['USD', 'EUR', 'RUB'];
  final List<Map<String, dynamic>> types = [
    {'label': 'Expense', 'value': 'expense', 'icon': Icons.arrow_upward, 'color': Colors.red},
    {'label': 'Income', 'value': 'income', 'icon': Icons.arrow_downward, 'color': Colors.green},
  ];

  final Map<String, List<String>> categoriesByType = {
    'expense': ['Food', 'Transport', 'Entertainment', 'Utilities', 'Shopping', 'Health', 'Education'],
    'income': ['Salary', 'Freelance', 'Gifts', 'Investments', 'Other'],
  };

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());

    selectedCurrency = widget.transaction.currency;
    selectedType = widget.transaction.type;
    selectedCategory = widget.transaction.category;

    if (!categoriesByType[selectedType]!.contains(selectedCategory)) {
      categoriesByType[selectedType]!.add(selectedCategory!);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addNewCategory() async {
    final newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Category name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add')),
          ],
        );
      },
    );

    if (newCategory != null && newCategory.isNotEmpty) {
      setState(() {
        categoriesByType[selectedType]!.add(newCategory);
        selectedCategory = newCategory;
      });
    }
  }

  void _updateTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final updates = {
      'description': _descriptionController.text,
      'amount': double.tryParse(_amountController.text) ?? 0,
      'category': selectedCategory,
      'currency': selectedCurrency,
      'type': selectedType,
    };

    context.read<TransactionsBloc>().add(
      UpdateTransactionEvent(widget.transaction.id ?? widget.transaction.localKey!, updates),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoriesByType[selectedType]!;

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
            child: ListView(
              children: [
                Text('Transaction type', style: Theme.of(context).textTheme.titleMedium),
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
                        setState(() {
                          selectedType = type['value'];
                          selectedCategory = categoriesByType[selectedType]!.first;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (value) => setState(() => selectedCategory = value),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addNewCategory,
                    )
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.notes)),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => selectedCurrency = value),
                  decoration: const InputDecoration(labelText: 'Currency', prefixIcon: Icon(Icons.monetization_on)),
                ),
                const SizedBox(height: 24),

                BlocBuilder<TransactionsBloc, TransactionsState>(
                  builder: (context, state) {
                    final isLoading = state is TransactionsLoading;
                    return ElevatedButton.icon(
                      icon: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(isLoading ? 'Updating...' : 'Save'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      onPressed: isLoading ? null : _updateTransaction,
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