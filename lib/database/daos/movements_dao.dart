import 'package:drift/drift.dart';
import '../tables/movements_table.dart';
import '../app_database.dart';

part 'movements_dao.g.dart';

@DriftAccessor(tables: [Movements])
class MovementsDao extends DatabaseAccessor<AppDatabase> with _$MovementsDaoMixin {
  MovementsDao(AppDatabase db) : super(db);

  Future<List<Movement>> getAllMovements() {
    return (select(movements)..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])).get();
  }

  Stream<List<Movement>> watchAllMovements() {
    return (select(movements)..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])).watch();
  }

  Future<Movement?> getMovementById(String id) {
    return (select(movements)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Movement>> getMovementsByDateRange(DateTime start, DateTime end) {
    return (select(movements)
          ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<Movement>> getMovementsByType(String type) {
    return (select(movements)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<Movement>> getMovementsByCategory(String categoryId) {
    return (select(movements)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<Movement>> searchMovements(String query) {
    return (select(movements)
          ..where((t) => t.description.like('%$query%'))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<double> getTotalByTypeAndDateRange(String type, DateTime start, DateTime end) {
    final query = selectOnly(movements)
      ..addColumns([movements.amount.sum()])
      ..where(movements.type.equals(type) &
          movements.date.isBiggerOrEqualValue(start) &
          movements.date.isSmallerOrEqualValue(end));
    return query.map((row) => row.read(movements.amount.sum()) ?? 0.0).getSingle();
  }

  Future<double> getTotalByCategoryAndDateRange(String categoryId, DateTime start, DateTime end) {
    final query = selectOnly(movements)
      ..addColumns([movements.amount.sum()])
      ..where(movements.categoryId.equals(categoryId) &
          movements.date.isBiggerOrEqualValue(start) &
          movements.date.isSmallerOrEqualValue(end));
    return query.map((row) => row.read(movements.amount.sum()) ?? 0.0).getSingle();
  }

  Future<List<CategoryTotal>> getCategoryTotalsByDateRange(DateTime start, DateTime end, {String? type}) {
    var whereCondition = movements.date.isBiggerOrEqualValue(start) & movements.date.isSmallerOrEqualValue(end);
    
    if (type != null) {
      whereCondition = whereCondition & movements.type.equals(type);
    }

    final query = selectOnly(movements)
      ..addColumns([
        movements.categoryId,
        movements.amount.sum(),
      ])
      ..where(whereCondition)
      ..groupBy([movements.categoryId]);

    return query.map((row) {
      return CategoryTotal(
        categoryId: row.read(movements.categoryId)!,
        total: row.read(movements.amount.sum()) ?? 0.0,
      );
    }).get();
  }

  Future<int> insertMovement(MovementsCompanion movement) {
    return into(movements).insert(movement, mode: InsertMode.replace);
  }

  Future<bool> updateMovement(MovementsCompanion movement) {
    return update(movements).replace(movement);
  }

  Future<int> deleteMovement(String id) {
    return (delete(movements)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteMovementsByCategory(String categoryId) {
    return (delete(movements)..where((t) => t.categoryId.equals(categoryId))).go();
  }
}

class CategoryTotal {
  final String categoryId;
  final double total;

  CategoryTotal({required this.categoryId, required this.total});
}

