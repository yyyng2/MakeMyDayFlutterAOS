import 'package:realm/realm.dart';

import '../../feature/ddayFeature/domain/entities/dday_entity.dart';
import '../../feature/scheduleFeature/domain/entities/schedule_entity.dart';

class RealmSchemaVersionManager {
  static const int currentVersion = 5;

  static Configuration getConfig() {
    return Configuration.local(
      [
        ScheduleEntity.schema,
        DdayEntity.schema
      ],
      schemaVersion: currentVersion,
      migrationCallback: _migrationCallback,
    );
  }

  // 마이그레이션 콜백
  static void _migrationCallback(Migration migration, int oldSchemaVersion) {
    // 버전별 마이그레이션 로직
    if (oldSchemaVersion < currentVersion) {
      _migrateV0ToV1(migration);
    }
  }

  // 버전 0에서 1로의 마이그레이션 예시
  static void _migrateV0ToV1(Migration migration) {
    final oldDdays = migration.oldRealm.all('DdayEntity');

    for (final oldDday in oldDdays) {
      final newDday = migration.findInNewRealm<DdayEntity>(oldDday);
      if (newDday == null) {
        continue;
      }

      newDday.repeatAnniversary = false;
      newDday.notificationType = 0;
    }
  }
}