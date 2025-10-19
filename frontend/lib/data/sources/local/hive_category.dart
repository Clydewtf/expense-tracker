import 'package:hive_flutter/hive_flutter.dart';

part 'hive_category.g.dart';


@HiveType(typeId: 1)
class HiveCategory extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  HiveCategory({
    required this.name,
    required this.type,
  });
}