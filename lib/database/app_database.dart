import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/movements_table.dart';
import 'tables/categories_table.dart';
import 'tables/settings_table.dart';
import 'daos/movements_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/settings_dao.dart';
import 'seed_data.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Movements, Categories, Settings],
  daos: [MovementsDao, CategoriesDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to == 2) {
          await m.addColumn(movements, movements.notes);
        }
      },
      beforeOpen: (OpeningDetails details) async {
        await _ensureSeedData();
      },
    );
  }

  Future<void> _ensureSeedData() async {
    final existingCategories = await (select(categories)..limit(1)).get();
    final existingMovements = await (select(movements)..limit(1)).get();
    
    if (existingCategories.isEmpty) {
      await _insertDefaultCategoriesAndSettings();
    }
    
    if (existingMovements.isEmpty) {
      await _insertDefaultMovements();
    }
  }

  Future<void> _insertDefaultCategoriesAndSettings() async {
    final defaultCategories = SeedData.getDefaultCategories();
    final defaultSettings = SeedData.getDefaultSettings();

    await batch((batch) {
      batch.insertAll(categories, defaultCategories, mode: InsertMode.insertOrIgnore);
      batch.insertAll(settings, defaultSettings, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _insertDefaultMovements() async {
    final defaultMovements = SeedData.getDefaultMovements();
    await batch((batch) {
      batch.insertAll(movements, defaultMovements, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> _insertDefaultData() async {
    final defaultCategories = SeedData.getDefaultCategories();
    final defaultSettings = SeedData.getDefaultSettings();
    final defaultMovements = SeedData.getDefaultMovements();

    await batch((batch) {
      batch.insertAll(categories, defaultCategories, mode: InsertMode.insertOrIgnore);
      batch.insertAll(settings, defaultSettings, mode: InsertMode.insertOrIgnore);
      batch.insertAll(movements, defaultMovements, mode: InsertMode.insertOrIgnore);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expense_manager.sqlite'));
    return NativeDatabase(file);
  });
}

