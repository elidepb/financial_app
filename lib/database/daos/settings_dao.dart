import 'package:drift/drift.dart';
import '../tables/settings_table.dart';
import '../app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);

  Future<Setting?> getSetting(String key) {
    return (select(settings)..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  Stream<Setting?> watchSetting(String key) {
    return (select(settings)..where((t) => t.key.equals(key))).watchSingleOrNull();
  }

  Future<List<Setting>> getAllSettings() {
    return select(settings).get();
  }

  Future<int> setSetting(String key, String value) {
    return into(settings).insert(
      SettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
      mode: InsertMode.replace,
    );
  }

  Future<int> deleteSetting(String key) {
    return (delete(settings)..where((t) => t.key.equals(key))).go();
  }

  Future<String?> getSettingValue(String key) async {
    final setting = await getSetting(key);
    return setting?.value;
  }

  Future<double?> getSettingValueAsDouble(String key) async {
    final value = await getSettingValue(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  Future<int?> getSettingValueAsInt(String key) async {
    final value = await getSettingValue(key);
    if (value == null) return null;
    return int.tryParse(value);
  }
}


