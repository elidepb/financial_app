import 'package:drift/drift.dart';
import 'categories_table.dart';

class Movements extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get categoryId => text().named('category_id').references(Categories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text().withLength(min: 1, max: 10)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

