import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1).unique()();
  TextColumn get icon => text().withLength(min: 1)();
  TextColumn get color => text().withLength(min: 1)();
  TextColumn get type => text().withLength(min: 1, max: 10)();
  IntColumn get displayOrder => integer().named('display_order').withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().named('is_default').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

