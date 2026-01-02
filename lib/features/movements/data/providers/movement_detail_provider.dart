import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/database/database_provider.dart';
import 'package:app_gestor_financiero/database/app_database.dart';

final movementDetailProvider = FutureProvider.family<Movement?, String>((ref, movementId) async {
  final movementsDao = ref.watch(movementsDaoProvider);
  return await movementsDao.getMovementById(movementId);
});


