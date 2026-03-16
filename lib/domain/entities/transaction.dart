class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.timestamp,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  final String id;
  final double amount;
  final String note;
  final String type;
  final String categoryId;
  final String categoryName;
  final DateTime timestamp;
  final int isSynced;
  final int isDeleted;

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';

  TransactionEntity copyWith({
    String? id,
    double? amount,
    String? note,
    String? type,
    String? categoryId,
    String? categoryName,
    DateTime? timestamp,
    int? isSynced,
    int? isDeleted,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
