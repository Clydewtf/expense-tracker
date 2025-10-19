import 'package:hive_flutter/hive_flutter.dart';


class CategoryRepository {
  static const String boxName = 'categories';
  late Box<String> _box;

  final Map<String, List<String>> _defaultCategoriesByType = {
    'expense': [
      'Food',
      'Transport',
      'Entertainment',
      'Utilities',
      'Shopping',
      'Health',
      'Education',
    ],
    'income': [
      'Salary',
      'Freelance',
      'Gifts',
      'Investments',
      'Other',
    ],
  };

  Future<void> init() async {
    _box = await Hive.openBox<String>(boxName);
  }

  List<String> getAllByType(String type) {
    final defaultCats = _defaultCategoriesByType[type] ?? [];
    final userCats = _box.values
        .where((c) => c.startsWith('$type:'))
        .map((c) => c.split(':')[1])
        .toList();

    final all = {...defaultCats, ...userCats};
    return all.toList();
  }

  Future<void> addCategory(String type, String name) async {
    if (name.trim().isEmpty) return;
    final key = '$type:$name';
    if (!_box.values.contains(key)) {
      await _box.add(key);
    }
  }

  Future<void> deleteCategory(String type, String name) async {
    final key = '$type:$name';
    final foundKey = _box.keys.firstWhere(
      (k) => _box.get(k) == key,
      orElse: () => -1,
    );
    if (foundKey != -1) await _box.delete(foundKey);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}