import 'package:drift/drift.dart';
import '../tables/categories_table.dart';
import '../app_database.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  Future<List<Category>> getAllCategories() {
    return (select(categories)..orderBy([(t) => OrderingTerm(expression: t.displayOrder, mode: OrderingMode.asc)])).get();
  }

  Stream<List<Category>> watchAllCategories() {
    return (select(categories)..orderBy([(t) => OrderingTerm(expression: t.displayOrder, mode: OrderingMode.asc)])).watch();
  }

  Future<Category?> getCategoryById(String id) {
    return (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Category>> getCategoriesByType(String type) {
    return (select(categories)
          ..where((t) => t.type.equals(type) | t.type.equals('both'))
          ..orderBy([(t) => OrderingTerm(expression: t.displayOrder, mode: OrderingMode.asc)]))
        .get();
  }

  Future<List<Category>> getDefaultCategories() {
    return (select(categories)
          ..where((t) => t.isDefault.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.displayOrder, mode: OrderingMode.asc)]))
        .get();
  }

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category, mode: InsertMode.replace);
  }

  Future<bool> updateCategory(CategoriesCompanion category) {
    return update(categories).replace(category);
  }

  Future<int> deleteCategory(String id) {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateDisplayOrder(List<String> categoryIds) async {
    await batch((batch) {
      for (var i = 0; i < categoryIds.length; i++) {
        batch.update(
          categories,
          CategoriesCompanion(
            id: Value(categoryIds[i]),
            displayOrder: Value(i),
          ),
          where: (t) => t.id.equals(categoryIds[i]),
        );
      }
    });
  }

  Future<int> getMaxDisplayOrder() async {
    final query = selectOnly(categories)
      ..addColumns([categories.displayOrder.max()]);
    final result = await query.getSingle();
    return result.read(categories.displayOrder.max()) ?? 0;
  }
}

