import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/features/movements/data/services/share_service.dart';
import 'package:app_gestor_financiero/features/movements/domain/usecases/export_movements.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

final exportMovementsUseCaseProvider = Provider<ExportMovements>((ref) {
  return ExportMovements();
});

