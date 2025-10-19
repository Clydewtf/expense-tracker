import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/category_repository.dart';
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

  String? selectedCurrency;
  String selectedType = 'expense';
  String? selectedCategory;

  final List<String> currencies = ['USD', 'EUR', 'RUB'];
  final List<Map<String, dynamic>> types = [
    {'label': 'Expense', 'value': 'expense', 'icon': Icons.arrow_upward, 'color': Colors.red},
    {'label': 'Income', 'value': 'income', 'icon': Icons.arrow_downward, 'color': Colors.green},
  ];

  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    selectedCurrency = (userState is UserLoaded) ? userState.user.defaultCurrency : 'USD';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = context.read<CategoryRepository>();
    final cats = repo.getAllByType(selectedType);
    setState(() {
      categories = cats;
      selectedCategory = cats.isNotEmpty ? cats.first : null;
    });
  }

  Future<void> _addNewCategory() async {
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
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newCategory != null && newCategory.isNotEmpty && mounted) {
      final repo = context.read<CategoryRepository>();
      await repo.addCategory(selectedType, newCategory);
      await _loadCategories();
      setState(() => selectedCategory = newCategory);
    }
  }

  void _onTypeChanged(String type) async {
    setState(() => selectedType = type);
    await _loadCategories();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate() || selectedCurrency == null || selectedCategory == null) return;

    final txn = TransactionModel(
      amount: double.parse(_amountController.text),
      category: selectedCategory!,
      description: _descriptionController.text,
      currency: selectedCurrency!,
      date: DateTime.now(),
      type: selectedType,
    );

    context.read<TransactionsBloc>().add(AddTransactionEvent(txn));
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is TransactionsLoaded) {
              Navigator.pop(context);
            }
          },
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
                      onSelected: (_) => _onTypeChanged(type['value']),
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

                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Add Transaction'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}