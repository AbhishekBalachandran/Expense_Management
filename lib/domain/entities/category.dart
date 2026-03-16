class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  final String id;
  final String name;
  final int isSynced;
  final int isDeleted;

  CategoryEntity copyWith({
    String? id,
    String? name,
    int? isSynced,
    int? isDeleted,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
