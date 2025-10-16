class TransactionModel {
  final int? id;
  final int? userId;
  final double amount;
  final String currency;
  final String category;
  final String? description;
  final DateTime date;
  final bool isSynced;
  int? localKey;

  TransactionModel({
    this.id,
    this.userId,
    required this.amount,
    required this.currency,
    required this.category,
    this.description,
    required this.date,
    this.isSynced = true,
    this.localKey,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      category: json['category'],
      description: json['description'] as String?,
      date: DateTime.parse(json['date']),
    );

  Map<String, dynamic> toJson() => {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'amount': amount,
      'currency': currency,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
}