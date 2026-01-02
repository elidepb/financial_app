import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    database.close();
  });
  return database;
});

final movementsDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).movementsDao;
});

final categoriesDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).categoriesDao;
});

final settingsDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).settingsDao;
});


