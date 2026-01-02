import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/database/database_provider.dart';
import 'package:app_gestor_financiero/database/app_database.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) async* {
  final categoriesDao = ref.watch(categoriesDaoProvider);
  await for (final categories in categoriesDao.watchAllCategories()) {
    yield categories;
  }
});

final categoriesByTypeProvider = StreamProvider.family<List<Category>, String>((ref, type) async* {
  final categoriesDao = ref.watch(categoriesDaoProvider);
  final categories = await categoriesDao.getCategoriesByType(type);
  yield categories;
  
  await for (final allCategories in categoriesDao.watchAllCategories()) {
    final filtered = allCategories.where((cat) => cat.type == type || cat.type == 'both').toList();
    yield filtered;
  }
});

