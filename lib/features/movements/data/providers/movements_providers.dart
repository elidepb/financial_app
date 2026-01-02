import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:app_gestor_financiero/database/database_provider.dart';
import 'package:app_gestor_financiero/database/mappers/movement_mapper.dart';
import 'package:app_gestor_financiero/database/app_database.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';
import 'package:uuid/uuid.dart';

final movementsStreamProvider = StreamProvider<List<MovementItem>>((ref) async* {
  final movementsDao = ref.watch(movementsDaoProvider);
  final categoriesDao = ref.watch(categoriesDaoProvider);

  await for (final movements in movementsDao.watchAllMovements()) {
    final categories = await categoriesDao.getAllCategories();
    final categoriesMap = {for (var cat in categories) cat.id: cat};
    
    final movementItems = MovementMapper.toMovementItems(movements, categoriesMap);
    yield movementItems;
  }
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) async* {
  final categoriesDao = ref.watch(categoriesDaoProvider);
  await for (final categories in categoriesDao.watchAllCategories()) {
    yield categories;
  }
});

final createMovementProvider = FutureProvider.family<void, CreateMovementParams>((ref, params) async {
  final movementsDao = ref.watch(movementsDaoProvider);
  final uuid = const Uuid();
  final now = DateTime.now();
  
  await movementsDao.insertMovement(
    MovementsCompanion.insert(
      id: uuid.v4(),
      amount: params.amount,
      description: params.description,
      categoryId: params.categoryId,
      date: params.date,
      type: params.type,
      notes: params.notes != null ? Value(params.notes!) : const Value.absent(),
      createdAt: now,
      updatedAt: now,
    ),
  );
});

final updateMovementProvider = FutureProvider.family<void, UpdateMovementParams>((ref, params) async {
  final movementsDao = ref.watch(movementsDaoProvider);
  final now = DateTime.now();
  
  final existing = await movementsDao.getMovementById(params.id);
  if (existing == null) {
    throw Exception('Movement not found: ${params.id}');
  }
  
  await movementsDao.updateMovement(
    MovementsCompanion(
      id: Value(existing.id),
      amount: Value(params.amount),
      description: Value(params.description),
      categoryId: Value(params.categoryId),
      date: Value(params.date),
      type: Value(params.type),
      notes: params.notes != null ? Value(params.notes!) : const Value.absent(),
      createdAt: Value(existing.createdAt),
      updatedAt: Value(now),
    ),
  );
});

final deleteMovementProvider = FutureProvider.family<void, String>((ref, id) async {
  final movementsDao = ref.watch(movementsDaoProvider);
  await movementsDao.deleteMovement(id);
});

class CreateMovementParams {
  final double amount;
  final String description;
  final String categoryId;
  final DateTime date;
  final String type;
  final String? notes;

  CreateMovementParams({
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
    required this.type,
    this.notes,
  });
}

class UpdateMovementParams {
  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final DateTime date;
  final String type;
  final String? notes;

  UpdateMovementParams({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
    required this.type,
    this.notes,
  });
}

